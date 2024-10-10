parse_payload <- function(poll, out_file = 'data/parsed.csv') {
  library(data.table)

  data_stream <- data.table(
    raw = poll
  )

  ## Grab receiver
  data_stream[, receiver := sub('\\*(\\d{6}).*', '\\1', raw)]

  ## Grab receiver time
  data_stream[, receiver_time := 
      sub(".*?(.{4}-..-.. ..:..:..(\\....)?),STS.*", '\\1', poll) |> 
      as.POSIXct(tz = 'UTC')
  ]

  ## Grab instrument data
  grab_numeric_data <- function(data, var_imp) {
    res <- sub(
      paste0('.*', var_imp, '=([^,]*).*'),
      '\\1',
      data
    )

    as.numeric(res) |> 
    suppressWarnings()
  }
  vars <- c('DC', 'PC', 'LV', 'BV', 'BU', 'I', 'T', 'DU', 'RU', 'N', 'NP')
  data_stream[, (vars) := lapply(vars, function(.) grab_numeric_data(raw, .))]


  ## Handle XYZ
  tilt <- sub('.*XYZ=([^,]*).*', '\\1', data_stream$raw)
  tilt <- ifelse(grepl("^[\\*\\|]", tilt), NA, tilt)

  data_stream[, let(
    X = sub('^([^:]*).*', '\\1', tilt),
    Y = sub('.*:(.*):.*', '\\1', tilt),
    Z = sub('.*:(.*)$', '\\1', tilt)
  )]



  ## Parse detections
  data_stream[
    grepl(
      "A(69|180)",
      raw
    ),
    detections :=
      # Select portions that have 5-6 (VR2C) or 8-9 (Rx-LIVE) sections
      #   Extras (6 and 9) are for ADC
      lapply(
        strsplit(raw, "#"),
        function(.) {
          .[ { gregexpr(",", text = .) |> sapply(length) } %in% c(5:6, 8:9) ]
        }
      ) |>

      # Remove leading and trailing characters, signal/noise/channel labels
      sapply(function(.) gsub("^..|, ?$|[SNC]=", "", .)) |>

      # check for ADC
      lapply(function(.) {
          char_check <- gsub("[^,]", "", .) |> nchar()
          if (char_check == 4) {
              cols <- c("receiver", "rec_seq", "datetimeutc", "codespace", "tag")
          } else if (char_check == 5) {
             cols <- c("receiver", "rec_seq", "datetimeutc", "codespace", "tag",
                      "sensor")
          } else if (char_check == 7) {
             cols <- c("receiver", "rec_seq", "datetimeutc", "codespace", "tag",
                      "signal", "noise", "channel")
          } else if (char_check == 8) {
             cols <- c("receiver", "rec_seq", "datetimeutc", "codespace", "tag",
                      "sensor", "signal", "noise", "channel")
          }
        
          fread(
              text = .,
              col.names = cols,
              colClasses = 'character',
              fill = TRUE
          )
      }
      ) |>
      rbindlist(fill = TRUE) |> 
      list() |> 
      as.character()
  ]


  fwrite(data_stream, out_file, append = TRUE)
}



parse_detections <- function(parsed_db) {
    parsed_db[, detections := gsub('""', '\"', detections)]
    
    # detections <- as.data.table(eval(parse(text = parsed_db$detections)))

    parsed_db[, detections := lapply(detections, function(.) {
      as.data.table(eval(parse(text = .)))
    })]

    detections <- rbindlist(parsed_db$detections, fill = TRUE)

    detections <- detections[, lapply(.SD, type.convert, as.is = T)]
    detections[, datetimeutc := as.POSIXct(datetimeutc, tz = 'UTC')]

    setorder(detections, datetimeutc)

    detections
}