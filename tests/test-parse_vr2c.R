source(file.path("..", "work", "parsers.R"))

test_that("VR2C 69kHz poll with no detections is parsed", {
    poll_nodetection <- paste0("*450281.0#20[0009],OK,#9A",
        "450281,221,2024-10-07 15:58:49,STS,",
        "DC=1229,PC=88504,LV=0.0,BV=3.5,BU=20.7,I=2.3,T=21.7,DU=0.1,RU=4.1,",
        "XYZ=-0.06:-0.28:-0.81,#7F>"
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




test_that("VR2C 69kHz poll with detections is parsed", {
    poll_detection <- paste0("*450281.0#20[0009],OK,#9A",
        "450281,238,2024-10-07 20:13:49,STS,",
        "DC=1235,PC=88607,LV=0.0,BV=3.5,BU=20.8,I=2.4,T=22.8,DU=0.1,RU=4.1,",
        "XYZ=-0.06:-0.28:-0.81,#7F",
        "450281,239,2024-10-07 20:02:07,A69-9001,6277,#A8",
        "450281,240,2024-10-07 20:07:12,A69-9001,6278,123,#A1>"
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
