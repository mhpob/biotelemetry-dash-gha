library(httr2)

resp <- 'https://api.github.com/repos/mhpob/biotelemetry-dash-gha/actions/workflows/ingest.yaml/dispatches' |> 
    request() |> 
    req_headers(
        Accept = "application/vnd.github+json",
        Authorization = "Bearer <ADD TOKEN HERE!!!!>",
        `X-GitHub-Api-Version` = "2022-11-28",
        .redact = "Authorization"
    ) |> 
    req_body_json(
        list(
            ref = "main",
            inputs = list(
                p = paste0("*450281.0#20[0009],OK,#9A",
        "450281,238,2024-10-07 20:13:49,STS,",
        "DC=1235,PC=88607,LV=0.0,BV=3.5,BU=20.8,I=2.4,T=22.8,DU=0.1,RU=4.1,",
        "XYZ=-0.06:-0.28:-0.81,#7F",
        "450281,239,2024-10-07 20:02:07,A69-9001,6277,#A8",
        "450281,240,2024-10-07 20:07:12,A69-9001,6278,123,#A1>"
                ) |> 
                shQuote()
            )
        )
    ) |> 
    req_perform()