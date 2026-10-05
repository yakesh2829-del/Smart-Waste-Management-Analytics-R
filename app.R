library(shiny)
library(ggplot2)
library(dplyr)
library(DT)
library(scales)
library(lubridate)

waste <- read.csv("data/waste_data.csv", stringsAsFactors = FALSE)
waste$Date <- as.Date(waste$Date)
waste$Month <- floor_date(waste$Date, "month")

ui <- fluidPage(
  tags$head(
    tags$title("NEXUS WASTE | Smart Waste Management Analytics"),
    tags$link(rel="preconnect", href="https://fonts.googleapis.com"),
    tags$link(rel="preconnect", href="https://fonts.gstatic.com", crossorigin=""),
    tags$link(href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Space+Grotesk:wght@500;600;700&display=swap", rel="stylesheet"),
    tags$link(rel="stylesheet", href="styles.css")
  ),
  tags$div(class="shell",
    tags$div(class="topbar",
      tags$div(class="brand",
        tags$div(class="brand-mark","♻"),
        tags$div(tags$div(class="brand-title","NEXUS WASTE"),tags$div(class="brand-sub","SMART MANAGEMENT ANALYTICS"))
      ),
      tags$div(class="nav",
        actionLink("nav_overview","Overview",class="nav-link active"),
        actionLink("nav_operations","Operations",class="nav-link"),
        actionLink("nav_recycling","Recycling",class="nav-link"),
        actionLink("nav_insights","Insights",class="nav-link"),
        actionLink("nav_data","Data Explorer",class="nav-link")
      ),
      tags$div(class="system-status",tags$span(class="status-dot"),"SYSTEM ONLINE")
    ),

    tags$div(class="hero",
      tags$div(class="hero-left",
        tags$div(class="eyebrow","URBAN RESOURCE INTELLIGENCE"),
        tags$h1("Turn waste into",tags$span(" better decisions.",class="accent")),
        tags$p("Monitor collection efficiency, recovery, vehicle utilization and neighborhood performance from one command center."),
        tags$div(class="hero-tags",tags$span("LIVE ROUTES"),tags$span("RECOVERY"),tags$span("EFFICIENCY"))
      ),
      tags$div(class="hero-graphic",
        tags$div(class="grid-lines"),
        tags$div(class="orb orb1"),tags$div(class="orb orb2"),
        tags$div(class="bin-icon","♻"),
        tags$div(class="graphic-label","CITY / 01")
      )
    ),

    tags$div(class="filters",
      tags$div(class="filter-heading","CONTROL PANEL"),
      tags$div(class="filter",dateRangeInput("date","Date range",start=min(waste$Date),end=max(waste$Date),format="dd M yyyy",separator=" → ")),
      tags$div(class="filter",selectInput("zone","Zone",c("All",sort(unique(waste$Zone))))),
      tags$div(class="filter",selectInput("waste_type","Waste type",c("All",sort(unique(waste$Waste_Type))))),
      tags$div(class="filter",selectInput("method","Collection method",c("All",sort(unique(waste$Collection_Method))))),
      actionButton("apply","APPLY",class="apply")
    ),

    tags$div(class="content",
      tabsetPanel(id="tabs",type="hidden",
        tabPanel("overview",
          tags$div(class="section-title",tags$div(tags$div(class="eyebrow2","COMMAND CENTER"),tags$h2("Waste network overview"),tags$p("Current performance across the selected operational scope."))),
          tags$div(class="kpi-grid",
            tags$div(class="kpi green",tags$div(class="kpi-top",tags$span("WASTE COLLECTED"),tags$b("♻")),tags$div(class="kpi-value",textOutput("kpi_waste")),tags$div(class="kpi-note","total kilograms")),
            tags$div(class="kpi cyan",tags$div(class="kpi-top",tags$span("RECOVERY RATE"),tags$b("↗")),tags$div(class="kpi-value",textOutput("kpi_recovery")),tags$div(class="kpi-note","material recovered")),
            tags$div(class="kpi purple",tags$div(class="kpi-top",tags$span("COLLECTION EFFICIENCY"),tags$b("◉")),tags$div(class="kpi-value",textOutput("kpi_eff")),tags$div(class="kpi-note","successful collections")),
            tags$div(class="kpi orange",tags$div(class="kpi-top",tags$span("AVG. RESPONSE"),tags$b("◷")),tags$div(class="kpi-value",textOutput("kpi_time")),tags$div(class="kpi-note","minutes per pickup")),
            tags$div(class="kpi red",tags$div(class="kpi-top",tags$span("OVERFLOW RATE"),tags$b("△")),tags$div(class="kpi-value",textOutput("kpi_overflow")),tags$div(class="kpi-note","reported overflow"))
          ),
          tags$div(class="grid3",
            tags$div(class="panel wide",tags$div(class="panel-head",tags$h3("Waste flow over time"),tags$span("MONTHLY")),plotOutput("trend",height="300px")),
            tags$div(class="panel",tags$div(class="panel-head",tags$h3("Waste composition"),tags$span("MATERIAL")),plotOutput("composition",height="300px"))
          ),
          tags$div(class="grid2",
            tags$div(class="panel",tags$div(class="panel-head",tags$h3("Zone performance"),tags$span("RECOVERY RATE")),plotOutput("zone_plot",height="320px")),
            tags$div(class="panel",tags$div(class="panel-head",tags$h3("Collection status"),tags$span("SERVICE")),plotOutput("status_plot",height="320px"))
          )
        ),

        tabPanel("operations",
          tags$div(class="section-title",tags$h2("Operations control"),tags$p("Inspect collection speed, vehicle load and zone-level service quality.")),
          tags$div(class="grid2",
            tags$div(class="panel",tags$div(class="panel-head",tags$h3("Vehicle utilization"),tags$span("CAPACITY")),plotOutput("vehicle_plot",height="330px")),
            tags$div(class="panel",tags$div(class="panel-head",tags$h3("Collection time"),tags$span("MINUTES")),plotOutput("time_plot",height="330px"))
          ),
          tags$div(class="grid2",
            tags$div(class="panel",tags$div(class="panel-head",tags$h3("Collection method"),tags$span("VOLUME")),plotOutput("method_plot",height="300px")),
            tags$div(class="panel",tags$div(class="panel-head",tags$h3("Service satisfaction"),tags$span("RATING")),plotOutput("satisfaction_plot",height="300px"))
          )
        ),

        tabPanel("recycling",
          tags$div(class="section-title",tags$h2("Recovery & recycling"),tags$p("Track how much collected material moves toward recovery.")),
          tags$div(class="insight-cards",
            tags$div(class="metric-card",tags$strong("Recovered material"),tags$span(textOutput("rec_kg"))),
            tags$div(class="metric-card",tags$strong("Average segregation"),tags$span(textOutput("seg_pct"))),
            tags$div(class="metric-card",tags$strong("Best material"),tags$span(textOutput("best_material")))
          ),
          tags$div(class="grid2",
            tags$div(class="panel",tags$div(class="panel-head",tags$h3("Recovery by material"),tags$span("KG")),plotOutput("recovery_plot",height="330px")),
            tags$div(class="panel",tags$div(class="panel-head",tags$h3("Segregation quality"),tags$span("PERCENT")),plotOutput("seg_plot",height="330px"))
          ),
          tags$div(class="panel",tags$div(class="panel-head",tags$h3("Recovery trend"),tags$span("MONTHLY")),plotOutput("recovery_trend",height="300px"))
        ),

        tabPanel("insights",
          tags$div(class="section-title",tags$h2("Smart insights"),tags$p("Decision-ready signals calculated from the filtered dataset.")),
          tags$div(class="alert-grid",
            tags$div(class="alert-card alert-good",tags$strong("Best zone"),tags$span(textOutput("best_zone"))),
            tags$div(class="alert-card alert-warn",tags$strong("Most overflow"),tags$span(textOutput("overflow_zone"))),
            tags$div(class="alert-card alert-info",tags$strong("Most used method"),tags$span(textOutput("best_method")))
          ),
          tags$div(class="panel",tags$div(class="panel-head",tags$h3("Waste vs. service quality"),tags$span("RELATIONSHIP")),plotOutput("scatter_quality",height="350px")),
          tags$div(class="panel",tags$div(class="panel-head",tags$h3("Operational summary"),tags$span("FILTERED DATA")),DTOutput("summary_table"))
        ),

        tabPanel("data",
          tags$div(class="section-title",tags$h2("Data explorer"),tags$p("Search, sort and export the underlying collection records.")),
          tags$div(class="table-panel",DTOutput("data_table"))
        )
      )
    ),
    tags$div(class="footer",tags$strong("NEXUS WASTE"),tags$span("Smart Waste Management Analytics • R + Shiny • Synthetic academic dataset"))
  ),

  tags$script(HTML("
    $(function(){
      function go(tab){
        $('#tabs li').each(function(){
          if($(this).text().trim().toLowerCase()===tab){ $(this).find('a').trigger('click'); }
        });
        $('.nav-link').removeClass('active');
        $('.nav-link').filter(function(){
          var t=$(this).text().toLowerCase();
          return (tab==='overview'&&t.indexOf('overview')>=0)||(tab==='operations'&&t.indexOf('operations')>=0)||(tab==='recycling'&&t.indexOf('recycling')>=0)||(tab==='insights'&&t.indexOf('insights')>=0)||(tab==='data'&&t.indexOf('data')>=0);
        }).addClass('active');
        window.scrollTo({top:0,behavior:'smooth'});
      }
      $('#nav_overview').on('click',function(e){e.preventDefault();go('overview')});
      $('#nav_operations').on('click',function(e){e.preventDefault();go('operations')});
      $('#nav_recycling').on('click',function(e){e.preventDefault();go('recycling')});
      $('#nav_insights').on('click',function(e){e.preventDefault();go('insights')});
      $('#nav_data').on('click',function(e){e.preventDefault();go('data')});
    });
  "))
)

server <- function(input, output, session){
  filtered <- eventReactive(input$apply,{
    x <- waste
    if(!is.null(input$date)) x <- x[x$Date>=input$date[1] & x$Date<=input$date[2],]
    if(input$zone!="All") x <- x[x$Zone==input$zone,]
    if(input$waste_type!="All") x <- x[x$Waste_Type==input$waste_type,]
    if(input$method!="All") x <- x[x$Collection_Method==input$method,]
    x
  },ignoreNULL=FALSE)

  output$kpi_waste <- renderText(paste0(comma(sum(filtered()$Waste_KG),accuracy=1)," kg"))
  output$kpi_recovery <- renderText(paste0(sprintf("%.1f",sum(filtered()$Recycled_KG)/sum(filtered()$Waste_KG)*100),"%"))
  output$kpi_eff <- renderText(paste0(sprintf("%.1f",mean(filtered()$Status=="Collected")*100),"%"))
  output$kpi_time <- renderText(paste0(sprintf("%.1f",mean(filtered()$Collection_Time_Min))," min"))
  output$kpi_overflow <- renderText(paste0(sprintf("%.1f",mean(filtered()$Overflow=="Yes")*100),"%"))

  dark_theme <- theme_minimal(base_family="DM Sans") + theme(
    plot.background=element_rect(fill="#111820",color=NA),
    panel.background=element_rect(fill="#111820",color=NA),
    text=element_text(color="#dce6e7"),
    axis.text=element_text(color="#8fa2a5"),
    axis.title=element_text(color="#9fb0b2"),
    panel.grid.major=element_line(color="#253239"),
    panel.grid.minor=element_blank(),
    legend.background=element_rect(fill="#111820",color=NA),
    legend.text=element_text(color="#9fb0b2"),
    legend.title=element_blank()
  )

  output$trend <- renderPlot({
    x<-filtered()%>%group_by(Month)%>%summarise(Waste=sum(Waste_KG),.groups="drop")
    ggplot(x,aes(Month,Waste))+geom_area(fill="#42d392",alpha=.22)+geom_line(color="#42d392",linewidth=1.3)+geom_point(color="#42d392",size=2)+labs(x=NULL,y="KG")+dark_theme
  })
  output$composition <- renderPlot({
    x<-filtered()%>%count(Waste_Type)
    ggplot(x,aes("",n,fill=Waste_Type))+geom_col(width=1,color="#111820")+coord_polar("y")+theme_void()+theme(legend.position="bottom",legend.text=element_text(color="#9fb0b2",family="DM Sans"),plot.background=element_rect(fill="#111820",color=NA))
  })
  output$zone_plot <- renderPlot({
    x<-filtered()%>%group_by(Zone)%>%summarise(Recovery=sum(Recycled_KG)/sum(Waste_KG)*100,.groups="drop")
    ggplot(x,aes(reorder(Zone,Recovery),Recovery))+geom_col(fill="#4bd6c2",width=.65)+coord_flip()+labs(x=NULL,y="% Recovery")+dark_theme
  })
  output$status_plot <- renderPlot({
    x<-filtered()%>%count(Status)
    ggplot(x,aes(reorder(Status,n),n))+geom_col(fill="#8f7cf4",width=.65)+labs(x=NULL,y="Records")+dark_theme
  })
  output$vehicle_plot <- renderPlot({
    x<-filtered()%>%group_by(Vehicle)%>%summarise(Util=mean(Utilization_Pct),.groups="drop")%>%arrange(desc(Util))
    ggplot(x,aes(reorder(Vehicle,Util),Util))+geom_col(fill="#52a9f7",width=.65)+coord_flip()+labs(x=NULL,y="% Utilization")+dark_theme
  })
  output$time_plot <- renderPlot({
    ggplot(filtered(),aes(Collection_Time_Min))+geom_histogram(bins=24,fill="#f0a85c",color="#111820")+labs(x="Minutes",y="Records")+dark_theme
  })
  output$method_plot <- renderPlot({
    x<-filtered()%>%count(Collection_Method)
    ggplot(x,aes(reorder(Collection_Method,n),n))+geom_col(fill="#42d392",width=.65)+coord_flip()+labs(x=NULL,y="Records")+dark_theme
  })
  output$satisfaction_plot <- renderPlot({
    x<-filtered()%>%count(Satisfaction)
    ggplot(x,aes(Satisfaction,n))+geom_col(fill="#8f7cf4",width=.55)+labs(x="Rating",y="Records")+dark_theme
  })
  output$recovery_plot <- renderPlot({
    x<-filtered()%>%group_by(Waste_Type)%>%summarise(Recovered=sum(Recycled_KG),.groups="drop")%>%arrange(Recovered)
    ggplot(x,aes(reorder(Waste_Type,Recovered),Recovered))+geom_col(fill="#42d392",width=.65)+coord_flip()+labs(x=NULL,y="Recovered KG")+dark_theme
  })
  output$seg_plot <- renderPlot({
    x<-filtered()%>%group_by(Waste_Type)%>%summarise(Seg=mean(Segregation_Pct),.groups="drop")
    ggplot(x,aes(reorder(Waste_Type,Seg),Seg))+geom_col(fill="#52a9f7",width=.65)+coord_flip()+labs(x=NULL,y="Segregation %")+dark_theme
  })
  output$recovery_trend <- renderPlot({
    x<-filtered()%>%group_by(Month)%>%summarise(Recovered=sum(Recycled_KG),.groups="drop")
    ggplot(x,aes(Month,Recovered))+geom_line(color="#42d392",linewidth=1.3)+geom_point(color="#42d392",size=2)+labs(x=NULL,y="Recovered KG")+dark_theme
  })
  output$scatter_quality <- renderPlot({
    x<-filtered()%>%slice_sample(n=min(nrow(filtered()),700))
    ggplot(x,aes(Waste_KG,Satisfaction))+geom_point(color="#52a9f7",alpha=.45,size=2)+geom_smooth(method="lm",se=FALSE,color="#f0a85c",linewidth=1)+labs(x="Waste collected (KG)",y="Satisfaction")+dark_theme
  })

  output$best_zone <- renderText({
    x<-filtered()%>%group_by(Zone)%>%summarise(r=sum(Recycled_KG)/sum(Waste_KG)*100,.groups="drop")%>%arrange(desc(r))
    if(nrow(x)) paste0(x$Zone[1]," • ",sprintf("%.1f%%",x$r[1])," recovery") else "—"
  })
  output$overflow_zone <- renderText({
    x<-filtered()%>%group_by(Zone)%>%summarise(o=mean(Overflow=="Yes")*100,.groups="drop")%>%arrange(desc(o))
    if(nrow(x)) paste0(x$Zone[1]," • ",sprintf("%.1f%%",x$o[1])) else "—"
  })
  output$best_method <- renderText({
    x<-filtered()%>%count(Collection_Method,sort=TRUE)
    if(nrow(x)) paste0(x$Collection_Method[1]," • ",comma(x$n[1])," records") else "—"
  })
  output$rec_kg <- renderText(paste0(comma(sum(filtered()$Recycled_KG),accuracy=1)," kg"))
  output$seg_pct <- renderText(paste0(sprintf("%.1f",mean(filtered()$Segregation_Pct)),"%"))
  output$best_material <- renderText({
    x<-filtered()%>%group_by(Waste_Type)%>%summarise(r=sum(Recycled_KG),.groups="drop")%>%arrange(desc(r))
    if(nrow(x)) paste0(x$Waste_Type[1]," • ",comma(x$r[1],accuracy=1)," kg") else "—"
  })

  output$data_table <- renderDT({
    datatable(filtered(),rownames=FALSE,filter="top",options=list(pageLength=12,scrollX=TRUE))
  })
  output$summary_table <- renderDT({
    x<-filtered()%>%group_by(Zone)%>%summarise(Records=n(),Waste_KG=sum(Waste_KG),Recovery_Pct=mean(Recycled_KG/Waste_KG)*100,Avg_Time=mean(Collection_Time_Min),Overflow_Pct=mean(Overflow=="Yes")*100,.groups="drop")
    datatable(x,rownames=FALSE,options=list(pageLength=10,scrollX=TRUE))
  })

  observeEvent(input$nav_overview,{updateTabsetPanel(session,"tabs","overview")})
  observeEvent(input$nav_operations,{updateTabsetPanel(session,"tabs","operations")})
  observeEvent(input$nav_recycling,{updateTabsetPanel(session,"tabs","recycling")})
  observeEvent(input$nav_insights,{updateTabsetPanel(session,"tabs","insights")})
  observeEvent(input$nav_data,{updateTabsetPanel(session,"tabs","data")})
}
shinyApp(ui,server)
