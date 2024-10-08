source(file.path("..", "work", "parsers.R"))

test_that("Rx-LIVE 69kHz poll with no detections is parsed", {
    poll_nodetection <- paste0("*667057.0#31[0009],OK,#9A",
        "667057,000,2021-06-01 19:36:21.024,STS,",
        "DC=23,PC=190,LV=12.0,T=25.1,DU=0.0,RU=0.0,XYZ=-0.06:0.94:-0.22,",
        "N=67.0,NP=39.0,#A9>"
    )

    parse_payload(
        poll_nodetection,
        file.path(tempdir(), "temp_db.csv")
    )

    parsed <- fread(file.path(tempdir(), "temp_db.csv"))

    # Correct number of columns
    expect_length(
        parsed,
        18
    )

    # Correct column names
    expect_named(
        parsed,
        c("raw", "receiver", "receiver_time", "DC", "PC", "LV", "BV", "BU", "I",
            "T", "DU", "RU", "N", "NP", "X", "Y", "Z", "detections")
    )

    # No information in detections column
    expect_true(
        is.na(parsed$detections)
    )

    unlink(file.path(tempdir(), "temp_db.csv"))
}
)




test_that("Rx-LIVE 69kHz poll with detections is parsed", {
    poll_detection <- paste0("*667057.0#31[0009],OK,#9A",
        "667057,005,2019-09-05 09:42:06.834,STS,",
        "DC=60,PC=624,LV=12.6,T=21.5,DU=0.0,RU=0.0,XYZ=-0.06:0.94:-0.22,",
        "N=67.0,NP=39.0,#66",
        "667057,006,2019-09-05 09:41:12.623,A69-1601,999,S=66.5,N=39.5,C=0, #7B",
        "667057,005,2019-09-04 16:35:22.361,A69-9006,1025,123,S=78.5,N=39.5,C=0, #60>"
    )

    parse_payload(
        poll_detection,
        file.path(tempdir(), "temp_db.csv")
    )

    parsed <- fread(file.path(tempdir(), "temp_db.csv"))

    # Correct number of columns
    expect_length(
        parsed,
        18
    )

    # Correct column names
    expect_named(
        parsed,
        c("raw", "receiver", "receiver_time", "DC", "PC", "LV", "BV", "BU", "I",
            "T", "DU", "RU", "N", "NP", "X", "Y", "Z", "detections")
    )

    # Information stored in detections column
    expect_type(
        parsed$detections,
        "character"
    )

    # Information is nominally a list
    expect_true(
        gsub("receiver.*$", "", parsed$detections) == "list("
    )

    unlink(file.path(tempdir(), "temp_db.csv"))
}
)