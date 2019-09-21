# ConfiLog
Product Line Configurations guided by Process Traces,<br>
How process mining can resolve configuration difficulties : An overview of the ConfiLog approach.

### Run
change paths of project in `web.xml` file: `WebContent/WEB-INF/web.xml`<br>
> you can rename `web.xml` -> `K_web.xml` and `H_web.xml` -> `web.xml`<br>
> houssem current paths saved in file `WebContent/WEB-INF/H_web.xml`<br>

live server: http://localhost:8080/SPLOT/


### Recommendation Algorithm:
XML data sets: `WebContent/datasets/{recommendation_type}/{name_of_model}/{*.xml}`<br><br>
`recommendation_types`: [ `no guidance(value = -1)`, `performance`, `flexibility`, `customization`, ]<br>
`name_of_model`: ex: `Eshop`<br>
`*.xml`: {pattern: NUMBERguidance.xml} , ex: `10guidance.xml`<br>
<hr>

> computing and refreshing delay rate is `1 second`, changeable in:<br>
> file: `WebContent/WEB-INF/templates/interactive_configuration_main2.ftl`<br>
> function: `algoProcess(){ }` -> `setTimeout(() => {...} , X_millisecond);`<br>


### Enviroment & tools:
- Web server: Tomcat 6.x^ (used: `Apache Tomcat/6.0.37` )
- Java (J2EE) + JavaScript (Native)
- Eclipse IDE
