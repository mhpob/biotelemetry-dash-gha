# Acoustic telemetry dashboard using the GitHub REST API

## Initial references:

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
