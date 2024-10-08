source(file.path("..", "work", "parsers.R"))
# source('work/parsers.R')

test_that("Parsed VR2C detections can be re-parsed", {
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

    detections <- parse_detections(parsed)

    expect_s3_class(
        detections,
        c("data.table", "data.frame")
    )

    expect_length(
        detections,
        6
    )

    expect_s3_class(
        detections$datetimeutc,
        "POSIXct"
    )

    unlink(file.path(tempdir(), "temp_db.csv"))
})


test_that("Parsed Rx-LIVE detections can be re-parsed", {
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

    detections <- parse_detections(parsed)

    expect_s3_class(
        detections,
        c("data.table", "data.frame")
    )

    expect_length(
        detections,
        9
    )

    expect_s3_class(
        detections$datetimeutc,
        "POSIXct"
    )

    unlink(file.path(tempdir(), "temp_db.csv"))
})