from diagrams import Diagram, Cluster
from diagrams.azure.network import DNSZones, LoadBalancers
from diagrams.azure.compute import VMScaleSet, AppServices
from diagrams.azure.database import SQLDatabases, CacheForRedis
from diagrams.azure.devops import ApplicationInsights

with Diagram("Azure 3-Tier Architecture", show=False):
    dns = DNSZones("DNS")
    lb = LoadBalancers("Load Balancer")

    with Cluster("Web Tier"):
        vmss = VMScaleSet("Web VMSS")

    with Cluster("App Tier"):
        app = AppServices("App Service")
        app_insights = ApplicationInsights("Monitoring")

    with Cluster("Data Tier"):
        sql = SQLDatabases("SQL DB")
        redis = CacheForRedis("Redis Cache")

    dns >> lb >> vmss >> app
    app >> sql
    app >> redis
    app >> app_insights
