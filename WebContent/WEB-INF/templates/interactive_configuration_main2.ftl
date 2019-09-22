exit<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!--
Design by Free CSS Templates
http://www.freecsstemplates.org
Released for free under a Creative Commons Attribution 2.5 License

Name       : Compromise
Description: A two-column, fixed-width design with dark color scheme.
Version    : 1.0
Released   : 20081103


Recommendation Algorithm implemented by: Khaled Alam (khaledalam.net@gmail.com)

-->
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="refresh" content="20000; url=/SPLOT/start.html"/>
<title>Welcome to the Software Product Lines Online Tools Homepage</title>

<link type="text/css" rel="stylesheet" href="splot.css"/>

<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/dojo/1.3/dijit/themes/nihilo/nihilo.css"/>

<script type="text/javascript"
	 	src="http://ajax.googleapis.com/ajax/libs/dojo/1.3/dojo/dojo.xd.js" 
	 	djConfig="parseOnLoad: true, isDebug: false, dojoBlankHtmlUrl: 'blank.html'">
</script>
<script type="text/javascript" src="js/ajax.js"></script> 

<#if !hasError>

<style type="text/css">

	.blackColor {
		color: black;
	}
	
	.guidanceBox {
		padding: 7px;
		border: 1px dashed #efdd51;
		display: inline-block;
		border-radius: 8px;
		min-width: 200px;
		font-size: 12px;
	    font-weight: bold;
	    color: green;
	    text-align: left;
	}

	.hintBox {
		margin-top: 0px;
		color: #292929;
		width: 880px;
		border: 1px solid #BABABA;
		background-color: white;
		padding-left: 10px;
		padding-right: 10px;
		margin-left: 10px;
		margin-bottom: 1em;
		-o-border-radius: 10px;
		-moz-border-radius: 12px;
		-webkit-border-radius: 10px;
		-webkit-box-shadow: 0px 3px 7px #adadad;
		border-radius: 10px;
		-moz-box-sizing: border-box;
		-opera-sizing: border-box;
		-webkit-box-sizing: border-box;
		-khtml-box-sizing: border-box;
		box-sizing: border-box;
		overflow: hidden;
	}
</style>


<!-- jQuery -->
<script src="http://code.jquery.com/jquery-3.3.1.slim.js" integrity="sha256-fNXJFIlca05BIO2Y5zh1xrShK3ME+/lYZ0j+ChxX2DA=" crossorigin="anonymous"></script>


<script type="text/javascript"> 

	var Partial = [];
	var EnabledActivites = [];
	var FinalOrder = [];
	var filesData = [];
	var guidanceType = '${guidanceType}';
	const INF = -1e9;
	
	if (guidanceType != "-1") {
	
		var guideXmlFilesPath = JSON.parse('${guideXmlFilesPath}');
		
		guideXmlFilesPath.forEach((file) => {
			let filePath = file.split('WebContent/')[1];
			let fileName = filePath.split('/');
			fileName = fileName[fileName.length-1];
			loadXMLFile(filePath, fileName);
		});
		
		console.log('xml files data:');
		console.log(filesData);
	}
	
	
	function xmlParser(xml, fileName) {
		var x, i, xmlDoc, txt = "";
		xmlDoc = xml.responseXML;
		x = xmlDoc.getElementsByTagName("Activity");
		y = xmlDoc.getElementsByTagName("Resource");
		var fileData = [];
		for (i = 0; i< x.length; i++) {
			let value = x[i].innerHTML;
			let parts = value.split('-');
			
			let optionName = parts[0] || '';
			let optionType = parts[1] || '';
			let optionSelected = parts[2] || '';
			let optionMode = parts[3] || '';
			let resource = y[i].innerHTML; 
			
			if(optionSelected == '1') optionSelected = 'select';
			else if(optionSelected == '0') optionSelected = 'deselect';
			
			fileData.push({
				'optionName': optionName,
				'optionType': optionType,
				'optionSelected': optionSelected,
				'optionMode': optionMode.toLowerCase(),
				'resource': resource, 
			});
			
			if (!EnabledActivites.includes(optionName))
				EnabledActivites.push(optionName);
		}
		let guidance = fileName.split('guidance')[0].trim();
		
		filesData.push({
			'fileName': fileName,
			'guidance': guidance,
			'data': fileData,
		});
		
		filesData.sort( (a, b) => (a.guidance < b.guidance) ? -1 : 1);
	}
	
	 function loadXMLFile(path, fileName) {
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			if (this.readyState == 4 && this.status == 200)xmlParser(this, fileName);
		};
		xmlhttp.open("GET", path, true);
		xmlhttp.send();
	}
	

	function checkAutoChanges() {
		
		let deselectedVariants = document.getElementsByClassName('deselectedFeature');
		for(let item of deselectedVariants) {
			let itemName = item.innerHTML.trim();
			if (itemName.length == '')continue;
			
			if (EnabledActivites.indexOf(itemName) != -1) {
				
				EnabledActivites.splice(EnabledActivites.indexOf(itemName), 1);
				
				Partial.push({
					'optionName': itemName,
					'optionSelected': 'deselect',
				});
			}
		}
		
		let selectedVariants = document.getElementsByClassName('selectedFeature');
		for(let item of selectedVariants) {
			let itemName = item.innerHTML.trim();
			if (itemName.length == '')continue;
			
			if (EnabledActivites.indexOf(itemName) != -1) {
				
				EnabledActivites.splice(EnabledActivites.indexOf(itemName), 1);
				
				Partial.push({
					'optionName': itemName,
					'optionSelected': 'select',
				});
			}
		}
		
		let normalVariants = document.getElementsByClassName('normalFeature');
		for(let item of normalVariants) {
			let itemName = item.innerHTML.trim();
			if (itemName.length == '')continue;
			
			if (EnabledActivites.indexOf(itemName) == -1 && Partial.indexOf(itemName) == -1) {
				EnabledActivites.push(itemName);
			}
			
			Partial.forEach((item, index, object) => {
				if (item.optionName == itemName){
					object.splice(index, 1);
				}
			});
			
		}
		
		
	}
	
	function DFS(text, object){
	
		if(object == null) return;
		
		if (object.innerHTML.indexOf(text) != -1) return true;
		
		if(object.children == null) return;
		
		for(let inner of object.children)  DFS(inner);
		
		if(object.childNodes ==  null) return;
			
		for(let inner of object.childNodes) DFS(inner);
	}
	
	function reSortList() {
		var parentNode = document.getElementById('_r_children');
		var e = document.getElementById('_r_children').children;
		[].slice.call(e).sort((a, b) => {
			var xx = -INF;
			var yy = -INF;
			FinalOrder.forEach((item, idx) => {
			
				if (DFS(item.activity, a) == true && xx == -INF) xx = idx;
				if (DFS(item.activity, b) == true && yy == -INF) yy = idx;
				
			});
			
			if (xx==yy)return 1;
			return (xx < yy) ? -1 : 1;
		}).forEach(function(val) {
			parentNode.appendChild(val);
		});
		document.getElementById('_r_children').innerHTML = parentNode.innerHTML;
	}
	
	function updateGuidance(operation, value){
		const opTypeConf = 'conf';
		const opTypeToggle = 'toggle';
		const opTypeUndo = 'undo';
		
		document.body.style.cursor = 'wait';
		
		checkAutoChanges();
		
		if (operation == opTypeUndo) {
			
			algoProcess();
			return;
		}
		
		
		let pureItem = (typeof value != 'number' ? value.split(":")[0] : value);
		let optionSelected = (typeof value != 'number' ? value.split(":")[1] : 0);
		optionSelected = (optionSelected == 1 ? 'select' : 'deselect');
		
		let itemTitle = document.getElementById(pureItem + '_name').getAttribute('title');
		
		Partial.push({
			'optionName': itemTitle,
			'optionSelected': optionSelected,
		});
		
		if (EnabledActivites.indexOf(itemTitle) != -1)
			EnabledActivites.splice(EnabledActivites.indexOf(itemTitle), 1);
		
		algoProcess();
		
	}
	
	function algoProcess() {
	
		// Wait till features tcheckAutoChangesable updates (auto select and deselected done if existed!) then calc recommendation! 
		setTimeout(() => {
		
			document.body.style.cursor = 'default';			
			
			let weights = [];
			filesData.forEach((file) => {
				
				let interSection = getInterSection(file.data, Partial);
				let weight = interSection/Partial.length;
				
				weights.push({
					'fileName': file.fileName,
					'weight': weight,
					'guidance': file.guidance,
				});
			});
			
			
			let FinalOrderTmp = [];
			console.log('Weights:'); console.log(weights);
			
			EnabledActivites.forEach((activity) => {
				
				// DO
				let doValue = INF;
				
				filesData.forEach((file) => {
					for(let item of file.data) { 
						if (item.optionName == activity && item.optionMode == 'manual') {
							for(let weight of weights) {
								if (weight.fileName == file.fileName){
									if (doValue == INF) doValue = 0;
									doValue += (weight.weight * file.guidance);
									
									break;
								}
							}
							break;
						}
					}
				});
				
				if (doValue == INF) doValue = 0;
				
				// DO NOT
				let donotValue = INF;
				
				filesData.forEach((file) => {
					var found = false;
					for(let item of file.data) {
						if (item.optionName == activity && item.optionMode == 'manual') {
							found = true;
							break;
						}
					}
					
					if (!found) {
						for(let weight of weights) {
							if (weight.fileName == file.fileName) {
								if (donotValue == INF) donotValue = 0;
								donotValue += (weight.weight * file.guidance);
								
								break;
							}
						}
					}
				});
				
				if (donotValue == INF) donotValue = 0;
				
				
				let betterChoise = 'default';
				
				for (let item of filesData[0].data) {
					if (item.optionName == activity) {
						betterChoise = item.optionSelected;
						break;
					}
				}
				
				
				FinalOrderTmp.push({
					'doValue': doValue,
					'donotValue': donotValue,
					'activity': activity,
					'valueABS': Math.abs(doValue-donotValue),
					'betterChoise': betterChoise, 
				});
			});
			FinalOrder = FinalOrderTmp;
			
		
			FinalOrder.sort((a, b) => {
			
				if (a.valueABS > b.valueABS) {
				
					if (guidanceType == "flexibility" || guidanceType == "customization")
						return 1;
					else
						return -1;		
				} else if (a.valueABS < b.valueABS) {
					if (guidanceType == "flexibility" || guidanceType == "customization")
						return -1;
					else
						return 1;
				}
				
				EnabledActivites.forEach((activity) => {
					if (activity == a.activity) return -1;
					else if (activity == b.activity) return 1;
				});
			});
			
			console.log('final order: ');
			console.log(FinalOrder);
			console.log("-------\n");
			
			
			reSortList();
			
			let orderList = '<ol type="1">';
			FinalOrder.forEach(function(item){
				orderList += '<li style="color:gray;">' + item.activity + ' - <span style="color:' 
					+  (item.betterChoise == 'select' ? 'green' : 'red') + ';">' + item.betterChoise + '</span></li>';
			});
			orderList += '</ol>';
			document.getElementById('recommendedOrder').innerHTML = orderList;
			
		}, 1000); // wait 1 second
		
	}
	
	
	function getInterSection(set1, set2){
		let ret = 0;
		set1.forEach((item1) => {
			set2.forEach((item2) => {
				ret += (item1.optionName == item2.optionName && item1.optionSelected == item2.optionSelected);
			});
		});
		return ret;
	}
	
	
	dojo.require("dijit.form.Button");
	dojo.require("dijit.Dialog");
	dojo.require("dijit.ProgressBar");	
	dojo.require("dojo.fx"); // for animate showing/hiding the Hint
	dojo.require("dojo.parser");
	
	/******************************************************
	*  On Load
	*******************************************************/
	dojo.addOnLoad(function() {
		buildFeatureModel();
		dijit.byId("confProgressBar").update({progress: ${countInstantiatedFeatures}, maximum: ${countFeatures} });
	});
	
	/******************************************************
	*  Show/Hide Hint (animation)
	*******************************************************/
	function hideHint() {
		dojo.fx.wipeOut({node: "animHintPost",duration: 1000}).play();
		document.getElementById("hintShortText").style.display = "block";
	}
	
	/******************************************************
	*  Hide Configuration Conflict Resolution dialog
	*******************************************************/
	function hideDialog() {
		dijit.byId('conflictingDecisionsDialog').hide();
	}
	
	/******************************************************
	*  Toggle feature as confirmed in the configuration conflict resolution dialog  
	*******************************************************/
	var toggleFeatureId = '';
	function toggleFeature(arguments) {
		updateConfigurationElements('toggle', 'toggleFeature', toggleFeatureId);
	}
	
	/******************************************************
	*  Set feature to be toggled   
	*******************************************************/
	function setToggleFeature(featureId) {
		toggleFeatureId = featureId;
	}
	
</script>

<script type="text/javascript"> 
<!--
	/******************************************************
	*  Detect conflicts when feature is toggled
	*******************************************************/
	function detectToggleConflicts(toggleFeatureId) {
		setToggleFeature(toggleFeatureId)
		ajaxObj = new sack("/SPLOT/SplotConfigurationServlet");
	  	ajaxObj.method = "GET";
	  	ajaxObj.onCompletion = function() 
	  	{
	  		dojo.byId('conflictingDecisionsDialogContent').innerHTML = ajaxObj.response;
	  		dojo.parser.parse();  // this is required for dojo to recognize dialog buttons
	  		dijit.byId('conflictingDecisionsDialog').show();
	  	}
	  	ajaxObj.runAJAX("action=detect_conflicts" + "&toggleFeature=" + toggleFeatureId);  		
	}
    
	/******************************************************
	*  Reset configuration
	*******************************************************/
	function resetConfiguration() {
	   window.location = "/SPLOT/SplotConfigurationServlet?action=interactive_configuration_main&op=reset";
	}
	
	/******************************************************
	*  Highlight selection button
	*******************************************************/
	function highlightSelectionButton(img,imgname) {
	  img.src = "/SPLOT/images/" + imgname;
	}
	
	/******************************************************
	*  Expand/collapse feature tree subtrees
	*******************************************************/
	function expandcollapse(featureid){
	   var el = document.getElementById(featureid + "_children");
	   var img = document.getElementById(featureid+"_icon"); 
	   if ( el.style.display != 'none' ) {
	       el.style.display = 'none';
	       img.src = "/SPLOT/images/plus.jpg";
	   }
	   else {
	       el.style.display = '';
	       img.src = "/SPLOT/images/minus.jpg";
	   }   
	}
	
	/******************************************************
	*  Build feature model
	*******************************************************/
	function buildFeatureModel() 
	{
		var featureObj;
		<#assign shift = 0>
		<#assign countSelectedFeatures = 0>
		<#list features as feature>
			<#if feature.feature_decision != "-1">
				<#assign countSelectedFeatures = countSelectedFeatures+1>
			</#if>
		    <#assign parentid = feature.feature_parentid + "_children"> 
			<#if feature.feature_parentid="">
		       <#assign parentid = "fm">
			</#if>
			// ${feature.feature_id} --> ${parentid}
			featureObj = document.getElementById('${parentid}');
			featureObj.innerHTML += 
				"<div id=\"${feature.feature_id}\">" + 
				"<div id=\"${feature.feature_id}_main\">" +
				"${feature.configurationFeatureElement?js_string}" + 
				"</div>" + 			
			 	"<div id=\"${feature.feature_id}_children\" style=\"position: relative; left: ${shift}px;\"></div>" +
			 	"</div>";
		</#list>
	} 

	/******************************************************
	*  Update configuration elements on page
	*******************************************************/
	function updateConfigurationElements(operation, parameter, value) {
		parameters = '';
		if (typeof parameter != 'undefined' && typeof value != 'undefined' ) {
			var today = new Date();
			var timeStamp = today.getUTCDate() +"/" + today.getUTCMonth() +"/" + today.getUTCFullYear() +" " + today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds() + ":" + today.getMilliseconds();   
			parameters = '&' + parameter + '=' + value + '&'+'timeStamp='+timeStamp;
		}
		
		// IMPORTANT UPDATE
		if (guidanceType != "-1") 
			updateGuidance(operation, value);
	
	    var xhrArgs = {
            url: "/SPLOT/SplotConfigurationServlet?action=interactive_configuration_updates&op=" + operation + parameters,
            sync : false,
            handleAs: "xml",
            load: function(response, ioArgs) {
            	
            	closeNotificationDialog();
				xmlDoc = response.documentElement;
				
				// Update Feature Model and list of features included in the current configuration
				features = xmlDoc.getElementsByTagName("feature");
				for( i = 0 ; i < features.length ; i++ ) {
					featureDivElement = features[i].getAttribute("id") + "_main";
					featureDivContent = features[i].childNodes[0].nodeValue;
					featureDivContent = featureDivContent.replace(/(\r\n|[\r\n])/g,'');
					document.getElementById(featureDivElement).innerHTML = featureDivContent;
				}
				
				/***********************************************************************************************     
				 * Identify operation: conf, completion, undo, toggle
				 *    conf: new features instantiated, a single new step to add 
				 *    completion: new features instantiated, a single new step to add
				 *    undo: new features to update, number of steps to eliminate from steps table
				 *    toggle: new features to update, number of steps to eliminate, steps to add
				***********************************************************************************************/     
				
				op = xmlDoc.getElementsByTagName("op")[0].getAttribute("value");
			
				countFeatures = xmlDoc.getElementsByTagName("countFeatures")[0].getAttribute("value");
				countInstantiatedFeatures = xmlDoc.getElementsByTagName("countInstantiatedFeatures")[0].getAttribute("value");
				
				if( (typeof countFeatures != 'undefined') && (typeof countInstantiatedFeatures != 'undefined') ) {
					//progressBarValue = Math.floor(countInstantiatedFeatures/countFeatures);
					dijit.byId("confProgressBar").update({progress: countInstantiatedFeatures, maximum: countFeatures });				
				}
			
				if ( op == "undo" || op == "toggle") {
					// Shrink configuration steps table
					confStepsTableObj = document.getElementById('confStepsTable');
					countUndoSteps = parseInt(xmlDoc.getElementsByTagName("countUndoSteps")[0].getAttribute("value"));
					for( i = 0 ; i < countUndoSteps ; i++ ) {
			  			confStepsTableObj.deleteRow(confStepsTableObj.rows.length-2);
			  		}
			  		// update auto-completion and configuration elements
					document.getElementById('auto-completion-element').style.display = '';
					document.getElementById('configuration-done-element').style.display ='none';						  		
		     	}
		        
				confSteps = xmlDoc.getElementsByTagName("step");
				
				for( i = 0 ; i < confSteps.length ; i++ ) {
					// expand configuration steps table 
		        	confStepDivContent = confSteps[i].childNodes[0].nodeValue;
		        	confStepDivContent = confStepDivContent.replace(/(\r\n|[\r\n])/g,'');
		     		
					confStepsTableObj = document.getElementById('confStepsTable');     		
		     		confStepsTableRow = confStepsTableObj.insertRow(confStepsTableObj.rows.length-1);
		     		 
		     		startIndex = confStepDivContent.indexOf("<td>");
		     		endIndex = confStepDivContent.indexOf("</td>", startIndex);
		     		cellIndex = 0;
		     		while( startIndex != -1 && endIndex != -1 ) {
		     			cellContent = confStepDivContent.substring(startIndex+4,endIndex);
					 	cellObj = confStepsTableRow.insertCell(cellIndex++);
					 	cellObj.innerHTML = cellContent;
		     			startIndex = confStepDivContent.indexOf("<td>", startIndex+1);
		     			endIndex = confStepDivContent.indexOf("</td>", endIndex+1)
					}
					
					// check if configuration is done
					done = xmlDoc.getElementsByTagName("done")[0].getAttribute("value");
					if ( done == 'true' ) {
						document.getElementById('auto-completion-element').style.display = 'none';
						document.getElementById('configuration-done-element').style.display ='';				
					}
		     	}
		     	
		     	checkAutoChanges();
            },
            error: function(error) {
                closeNotificationDialog();                
                alert('Oops, SPLOT behaved like a bad boy :) If the error persists contact the SPLOT team.');
            }
        }
		triggerNotificationDialog('wait', 'SPLOT Product Configurator', 'Processing ...');
        dojo.xhrGet(xhrArgs);   
	}		
-->


</script>

<script type="text/javascript">

<!--
	/******************************************************
	*  Close notification dialog 
	*******************************************************/
	function closeNotificationDialog() {
		dijit.byId('notificationDialog').hide();
	}
			
	/******************************************************
	*  Trigger notification dialog 
	*******************************************************/
	function triggerNotificationDialog(opType, title, message) {		
		dojo.byId('notificationDialogContent').innerHTML = message;
		if ( opType == 'wait' ) {
			dojo.byId('notificationDialogContentLoadingImage').style.display = 'block';
			dojo.byId('errorImage').style.display = 'none';
			dojo.byId('NotificationDialogOkButton').style.display = 'none';
		}
		else if ( opType == 'message' ) {
			dojo.byId('notificationDialogContentLoadingImage').style.display = 'none';
			dojo.byId('errorImage').style.display = 'none';
			dojo.byId('NotificationDialogOkButton').style.display = 'block';
		} 
		else if ( opType == 'error' ) {
			dojo.byId('errorImage').style.display = 'block';
			dojo.byId('notificationDialogContentLoadingImage').style.display = 'none';
			dojo.byId('NotificationDialogOkButton').style.display = 'block';
		} 
		dijit.byId('notificationDialog').attr('title', title);
		dijit.byId('notificationDialog').show();
	}
--> 
</script>

</#if>

</head>
<body class="nihilo">

<!-- dialog for conflict resolution -->
<div dojoType="dijit.Dialog"
	 style="display:none" 
	 id="conflictingDecisionsDialog" 
	 title="Configuration Conflict Resolution"
	 execute="toggleFeature(arguments[0])">	 
	 <div id="conflictingDecisionsDialogContent"></div>
</div>

<div id="header"><div id="logo"><img src="images/splot.jpg"/></div></div> 

<!--  Notification Dialog -->
<div dojoType="dijit.Dialog"
	 style="display:none" 
	 id="notificationDialog" 
	 title=""
	 execute="">	
	 <div>
	 	<table border="0" width="100%" cellpadding="10">
	 	<tr><td align="center">
		 	<img id="errorImage" style="display:none" src="images/error_icon.jpg"/>
			<span id="notificationDialogContent"></span>
	 	</td></tr>
	 	<tr><td align="center">
	 		<img id="notificationDialogContentLoadingImage" style="display:none" src="images/loading.gif"/>
	 		<span id="NotificationDialogOkButton">
	    		<button dojoType="dijit.form.Button" type="button" onclick="dijit.byId('notificationDialog').hide();return false;">OK</button>
	    	</span>
	 	</td></tr>
	 	</table>
	</div>
</div>

<!-- end #header --> 
<div id="menu"> 
    <ul> 
        <li><a href="index.html">Home</a></li> 
        <li><a href="feature_model_edition.html">Product Line Model Editor</a></li> 
        <li class="first"><a href="product_configuration.html">Product Line Configuration</a></li> 
        <li><a href="feature_model_repository.html">Product Line Model Repository</a></li> 
        <li><a href="contact_us.html">Contact Us</a></li> 
    </ul> 
</div> 
<!-- end #menu --> 

<div id="wrapper"> 
<div class="btm"> 
	<div id="page"> 
		<div id="content"> 
			<#if hasError>
				<div class="post"> 
					<div  class="entry">
						<p><span class="errorMessage">ERROR: ${errorMessage}.</span></p>
						<p><a href="javascript:history.back()">Back</a></p>
					</div>
				</div>						
			<#else>				
				
				<div class="post"> 
					<h1 class="title"><a href="#">${modelName} (${countFeatures} variants)</a></h1>
				</br></br>
			<input class="selectedFeature" id="originatorName" type="text" value="Originator Name" onkeyup="checkOriginatorName()" size="17"/> &ensp; <br>
			
			<b id="historyBox" class="blackColor" style="display: none;"></b>
								
			</br></br>					 				

<p><table width=820 border=0>
							<tr>
							<td align=left valign=top>
								<div id="fm">
								</div>
							</td>
							<td align=center valign=top>
								<span class="guidanceBox">
									<b class="blackColor">Guidance type:</b> <span id="guidanceType">${guidanceType}</span><hr>
									<b class="blackColor">recommended order:</b> <span id="recommendedOrder"></span><br>
								</span>	
							</td>
							<td align=right valign=top>
							<!--	
								<span>
									<p><b>Legend</b>:
									<br><img src="/SPLOT/images/checkmark.gif">select feature&nbsp;&nbsp;&nbsp;
									<br><img src="/SPLOT/images/crossmark.gif">deselect feature&nbsp;&nbsp;&nbsp;
									<br><img src="/SPLOT/images/toggle.gif">toggle feature&nbsp;&nbsp;&nbsp;
									<br><img src="/SPLOT/images/manual.gif">manual decision&nbsp;&nbsp;&nbsp;
									<br><img src="/SPLOT/images/propagated.gif">propagated decision&nbsp;&nbsp;&nbsp;
									<br><img src="/SPLOT/images/auto-completion.gif">auto-completion decision&nbsp;&nbsp;&nbsp;
									</p>
								</span>
							-->
								<#assign numColumns = 6>								
								<table class="standardTableStyle" id="confStepsTable">
									<tr><td colspan='${numColumns}' class="standardHighlight1">
										<b>Configuration Steps</b> [<a title="Reload feature model and restarts configuration" href="javascript:resetConfiguration()">reset</a>]
									</td></tr>
									<tr><td colspan="${numColumns}">
									<div id="confProgressBar" dojoType="dijit.ProgressBar" style="width:100%" maximum="100"></div>
									</td></tr>
									<tr>
										<th>Step</th>
										<th>Decision</th>
										<th>#Decisions<br><small>(cummulative)</small></th>
										<th>#Propagations<br><small>(at step)</small></th>
										<th>#SAT checks<br><small>(at step)</small></th>
										<th>SAT time<br><small>(at step)</small></th>
									</tr>
									<#list steps as step>
										${step.configurationStepElement}
									</#list>
									<tr><td colspan=${numColumns}>
										<span id="last_step_row">
											<span style="display:block;" id="configuration-done-element">
												<span class="standardHighlight1">Done!</span>
												(Export configuration: 
												<a href="#" onclick="exportCSV()" >CSV file</a> |  
												<a target="_new" href="/SPLOT/SplotConfigurationServlet?action=export_configuration_xml">XML</a>)
											</span>
											<span style="display:block;" id="auto-completion-element">
												<img title="Automatically completes configuration" src="/SPLOT/images/auto-completion.gif"/>
												Auto-completion: 
												<a title="Attempts to DESELECT all remaining features" href="javascript:updateConfigurationElements('completion','precedence','false')">Less Features</a> | 
												<a title="Attempts to SELECT all remaining features" href="javascript:updateConfigurationElements('completion','precedence','true')">More Features</a> 
											</span>
											
															</span>
									</td></tr>
								</table>	
								
								
								
					<table> 									<tr align=top><td id="detailsBtn" align="center" colspan="2"><button class="standardHighlight1" type="button" onclick="loadXMLDocc()">Detailed Reco</button><br><p id="democ">Ready!</p></td><td id="flexBtn" align="center" colspan="2"><button class="standardHighlight1" type="button" onclick="loadXMLDoc()">Flexible Reco</button><br><p id="democ">Ready!</p></td></tr>
					
					 </table>
						    
						  
															</td></tr>
								
							
						</table></p>
					</div> <!-- entry -->
				</div> <!-- post -->
			</#if> <!-- error check --> 
		</div> <!-- content --> 
		<div style="clear: both;">&nbsp;</div> 
	</div> 
	<!-- end #page --> 
</div> 
</div> 

<div id="footer"> 
    <p>Centre de Recherche en Informatique, Universite Pantheon Sorbonne Paris 1 / Laboratoire de Recherche RIADI, Universite de la Mannouba</p>
</div> 
<!-- end #footer --> 

<script>

	var guidanceTypeInner = document.getElementById("guidanceType").innerText.trim();
	
	guidanceTypeInner = (guidanceType == "-1" ? "No" : guidanceTypeInner);
	guidanceTypeInner = guidanceTypeInner[0].toUpperCase() +  guidanceTypeInner.slice(1);
	 
	document.getElementById("guidanceType").innerHTML = guidanceTypeInner;
	
	
	// No guidance
	if (guidanceType == -1) {
		document.getElementsByClassName("guidanceBox")[0].style.display = "none";
		document.getElementById("originatorName").readOnly = true;
	}
	
	if (guidanceType == "performance") {
		document.getElementById("detailsBtn").style.display = "none";
		document.getElementById("flexBtn").style.display = "none";
		document.getElementById("originatorName").readOnly = true;
	}
	
	if (guidanceType == "flexibility") {
		document.getElementById("detailsBtn").style.display = "none";
		document.getElementById("flexBtn").style.display = "block";
		document.getElementById("originatorName").readOnly = true;
	}

	if (guidanceType == "customization") {
		document.getElementById("detailsBtn").style.display = "block";
		document.getElementById("flexBtn").style.display = "none";
	}
 
	function exportCSV() {
	
		var originatorName = document.getElementById('originatorName').value || '';
	
		window.open(
			'/SPLOT/SplotConfigurationServlet?action=export_configuration_csv&originatorName=' + originatorName + '&recommendationType=' + guidanceType,
			'_blank'
		);
	}
	
	function checkOriginatorName() {
		var originatorName = document.getElementById('originatorName').value.trim() || '';
		
		if (originatorName == "") {
			document.getElementById('historyBox').style.display = "none";
		}else  {
			document.getElementById('historyBox').style.display = "block";
		}
		
		let innerH = originatorName + " your last config:<br>";
		
		filesData.forEach((file) => {
			file.data.forEach((item) => {
				let resource = item.resource;
				if (resource == originatorName) {
					innerH += item.optionName + " - " + item.optionSelected + "<br>";
				}
			});
		});
		
		document.getElementById('historyBox').innerHTML = innerH;
	}
	
 function loadXMLDoc() {
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {
			myFunction(this);
		}
	};
	xmlhttp.open("GET", "Rapid.xml", true);
	xmlhttp.send();
}

function myFunction(xml) {
	var x, i, xmlDoc, txt;
	xmlDoc = xml.responseXML;
	txt = "";
	x = xmlDoc.getElementsByTagName("Node");
	for (i = 0; i< x.length; i++) {
		txt += x[i].getAttribute('activity') + "<br>";
	}
	document.getElementById("demo").innerHTML = txt;
}



function loadXMLDocc() {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      myFunction1(this);
    }
  };
  xmlhttp.open("GET", "detailed.xml", true);
  xmlhttp.send();
}

function myFunction1(xml) {
  var x, i, xmlDoc, txt;
  xmlDoc = xml.responseXML;
  txt = "";
  x = xmlDoc.getElementsByTagName("Activity");
  for (i = 0; i< x.length; i++) {
    txt += x[i].childNodes[0].nodeValue + "<br>";
  }
  document.getElementById("democ").innerHTML = txt;
}



var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("UA-1626595-6");
pageTracker._trackPageview();
} catch(err) {}

</script>


</body>
</html>