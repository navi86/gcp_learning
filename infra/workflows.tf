#
resource "google_service_account" "workflows_service_account" {
  account_id   = "workflows-sa"
  display_name = "Workflows Service Account"
  project      = local.project_infra.project_id
}

resource "google_workflows_workflow" "workflows_example" {
  name            = "sample-workflow"
  region          = var.region
  description     = "A sample workflow"
  service_account = google_service_account.workflows_service_account.id
  project         = local.project_infra.project_id
  source_contents = <<-EOF
  # This is a sample workflow, feel free to replace it with your source code
  #
  # This workflow does the following:
  # - reads current time and date information from an external API and stores
  #   the response in CurrentDateTime variable
  # - retrieves a list of Wikipedia articles related to the day of the week
  #   from CurrentDateTime
  # - returns the list of articles as an output of the workflow
  # FYI, In terraform you need to escape the $$ or it will cause errors.

  - getCurrentTime:
      call: http.get
      args:
          url: https://us-central1-workflowsample.cloudfunctions.net/datetime
      result: CurrentDateTime
  - readWikipedia:
      call: http.get
      args:
          url: https://en.wikipedia.org/w/api.php
          query:
              action: opensearch
              search: $${CurrentDateTime.body.dayOfTheWeek}
      result: WikiResult
  - returnOutput:
      return: $${WikiResult.body[1]}
EOF
}
