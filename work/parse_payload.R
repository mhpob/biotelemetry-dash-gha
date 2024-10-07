#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)
poll <- as.numeric(args[1])

library(data.table)

# VR2C, no detections
# poll  <- "*450281.0#20[0009],OK,#9A450281,221,2024-10-07 15:58:49,STS,DC=1229,PC=88504,LV=0.0,BV=3.5,BU=20.7,I=2.3,T=21.7,DU=0.1,RU=4.1,XYZ=-0.06:-0.28:-0.81,#7F>"
# VR2C, detections
poll <- "*450281.0#20[0009],OK,#9A450281,238,2024-10-07 20:13:49,STS,DC=1235,PC=88607,LV=0.0,BV=3.5,BU=20.8,I=2.4,T=22.8,DU=0.1,RU=4.1,XYZ=-0.06:-0.28:-0.81,#7F450281,239,2024-10-07 20:02:07,A69-9001,6277,#A8450281,240,2024-10-07 20:07:12,A69-9001,6278,123,#A1>"

# Rx-LIVE, no detections
# poll <- "*667057.0#31[0009],OK,#9A667057,000,2021-06-01 19:36:21.024,STS,DC=23,PC=190,LV=12.0,T=25.1,DU=0.0,RU=0.0,XYZ=-0.06:0.94:-0.22,N=67.0,NP=39.0,#A9>"
# Rx-LIVE, detections
# poll <- "*667057.0#31[0009],OK,#9A667057,005,2019-09-05 09:42:06.834,STS,DC=60,PC=624,LV=12.6,T=21.5,DU=0.0,RU=0.0,XYZ=-0.06:0.94:-0.22,N=67.0,NP=39.0,#66667057,006,2019-09-05 09:41:12.623,A69-1601,999,S=66.5,N=39.5,C=0, #7B667057,005,2019-09-04 16:35:22.361,A69-9006,1025,123,S=78.5,N=39.5,C=0, #60>"

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

    # Remove leading characters
    sapply(function(.) gsub("^..", "", .)) |>

    # check for ADC
    lapply(function(.) {
        char_check <- gsub("[^,]", "", .) |> nchar()
        if (char_check == 5) {
            cols <- c("receiver", "rec_seq", "datetimeutc", "codespace", "tag", "")
        } else if (char_check == 6) {
           cols <- c("receiver", "rec_seq", "datetimeutc", "codespace", "tag",
                    "sensor", "")
        } else if (char_check == 8) {
           cols <- c("receiver", "rec_seq", "datetimeutc", "codespace", "tag",
                    "signal", "noise", "channel", "")
        } else if (char_check == 9) {
           cols <- c("receiver", "rec_seq", "datetimeutc", "codespace", "tag",
                    "sensor", "signal", "noise", "channel", "")
        }
        
        fread(
            text = .,
            col.names = cols,
            colClasses = 'character',
            fill = TRUE
        )[, !""]
    }
    ) |>
    as.character()
]
fwrite(raw_db, '/data/db_parsed.csv')








## Parse instrument data

receiver <- sub("^\\*(\\d{6}).*", "\\1", poll)

date_time <- sub(".*?(.{4}-..-.. ..:..:..(\\....)?),STS.*", '\\1', poll) |> 
    as.POSIXct(tz = 'UTC')

fields <- gsub('.*STS', '', poll) |> 
    strsplit('[=,]', x = _) |> 
    unlist() |>
    grep('^[A-Z]', x = _, value = T)

data <- sapply(fields,
    function(x) {
        sub(
        paste0(".*", x, "=([^,]*).*"),
        "\\1",
        poll
        )
    })

data['X'] <- sub('^([^:]*).*', '\\1', data['XYZ'])
data['Y'] <- sub('.*:(.*):.*', '\\1', data['XYZ'])
data['Z']  <- sub('.*:(.*)$', '\\1', data['XYZ'])
data <- data[!names(data) == 'XYZ']
mode(data) <- 'numeric'


## Parse tag information