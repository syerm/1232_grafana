provider "azurerm" {
  features{}
}
data "azurerm_application_insights" "example" {
  name="test-grafana-avaliability"
  resource_group_name = "dashboard06"
}

resource "azurerm_application_insights_web_test" "example" {
  name                    = "tf-test-appinsights-webtest"
  location                = "eu-north"
  resource_group_name     = data.azurerm_application_insights.example.resource_group_name
  application_insights_id = data.azurerm_application_insights.example.id
  kind                    = "ping"
  frequency               = 300
  timeout                 = 60
  enabled                 = true
  geo_locations           = ["emea-gb-db3-azr", "emea-se-sto-edge", "us-va-ash-azr", "emea-nl-ams-azr", "us-fl-mia-edge"]

  configuration = <<XML
<WebTest Name="WebTest1" Id="ABD48585-0831-40CB-9069-682EA6BB3583" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="0" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
  <Items>
    <Request Method="GET" Guid="a5f10126-e4cd-570d-961c-cea43999a200" Version="1.1" Url="https://dashboard.internal.aurora.equinor.com/grafana/login" ThinkTime="0" Timeout="300" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
  </Items>
</WebTest>
XML

}
resource "azurerm_monitor_action_group" "main" {
  name                = "omnia_aurora_notifications"
  resource_group_name = data.azurerm_application_insights.example.resource_group_name
  short_name          = "omnia_alert"
  email_receiver {
    name                    = "stanislav"
    email_address           = "syer@equinor.com"
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_metric_alert" "example" {
  name                = "example-metricalert"
  resource_group_name = data.azurerm_application_insights.example.resource_group_name
  scopes = [azurerm_application_insights_web_test.example.id,data.azurerm_application_insights.example.id]
  description         = "PING test alert"

application_insights_web_test_location_availability_criteria {
  web_test_id = azurerm_application_insights_web_test.example.id
  component_id = data.azurerm_application_insights.example.id
  failed_location_count = 2
}

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}