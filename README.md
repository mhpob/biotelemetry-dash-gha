# Acoustic telemetry dashboard using the GitHub REST API

## Tasks

  - Code server-side munging of ingested data
  - Commit to repository as CSV "database"
  - Code transfer of data from ingest to build-dash steps of GHA
  - Describe remote (field) server set up
    - Needs: RS-485, cellular modem, libcurl or something like it
      - shell script?
  - [Convert into GitHub App](https://docs.github.com/en/apps/creating-github-apps/registering-a-github-app/registering-a-github-app)

## Initial references

### GitHub Actions (GHA)

  - Configuration of a GHA workflow to take inputs. Inputs will come from the body of the POST webhook sent by the remote server
    - <https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows#providing-inputs>
    - <https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/accessing-contextual-information-about-workflow-runs#inputs-context>
  - Configuration of the GHA webhook
    - <https://docs.github.com/en/rest/actions/workflows?apiVersion=2022-11-28#create-a-workflow-dispatch-event>

### Quarto Dashboards

  - General reference
    - <https://quarto.org/docs/dashboards/>
  - Example workflows using R targets
    - <https://github.com/tail-Winds/rtwb-flyway>
    - <https://github.com/mhpob/henrico-planning-agenda>

### Innovasea cabled instrument ASCII output

  - Rx-LIVE
    - <https://go.innovasea.com/rx_live_receiver_manual.pdf>
  - VR2C
    - <https://go.innovasea.com/vr2c_manual.pdf>
    - Example poll, no detection logged:
      - *450281.0#20[0009],OK,#9A\n450281,221,2024-10-07 15:58:49,STS,DC=1229,PC=88504,LV=0.0,BV=3.5,BU=20.7,I=2.3,T=21.7,DU=0.1,RU=4.1,XYZ=-0.06:-0.28:-0.81,#7F>
