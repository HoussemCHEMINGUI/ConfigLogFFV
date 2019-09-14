<#if hasError>
	<p><span class="errorMessage">ERROR: ${errorMessage}.</span></p>
	<p><a href="javascript:history.back()">Back</a></p>
<#else>
	<style>
		.guianceBlock {
			padding-top: 15px;
			display: inline-block;
		}
	</style>
	
	<script type="text/javascript">
	<!--
	 function sortModels(sortBy)
	{
		ajax_loadContent('_model_repository','/SPLOT/SplotAnalysesServlet?action=select_model&enableSelection=${enableSelection?string}&selectionMode=${selectionMode}&serviceURL=${serviceURL}&serviceHTTPMethod=${serviceHTTPMethod}&serviceAction=${serviceAction}&sortby='+sortBy);
	}
	
	-->
	</script>
	<div id="_model_repository">
		<#compress>
		<#if enableSelection>
			<#if selectionMode="multiple">
			
			  <form action="${serviceURL}" method="${serviceHTTPMethod}">
			  <input type="hidden" name="action" value="${serviceAction}">
			  <b>Please, type the URL of your own feature models AND/OR select models from the table below and</b>
			  <input class="standardHighlight1" type="submit" value="Click Here"/>
			  <p style="margin: 10px 0px 0px 0px">Your model's URLs (in the <a href="sxfm.html">SXFM format</a>) starting with "http://" (one per line):</p>
			  <p style="margin: 0px 0px 10px 0px"><textarea name="userModels" rows=3 cols="80"></textarea></p>
			<#elseif selectionMode="single">
			  <form action="${serviceURL}" method="${serviceHTTPMethod}">
			  <input type="hidden" name="action" value="${serviceAction}">
			  <input type="hidden" name="guidanceType" id="guidanceType" value="-1">
			  <input type="hidden" name="op" value="reset">
			  <b>Select a product line model from the table below and</b>
			  <input class="standardHighlight1" type="submit" value="Click Here"/>
			</#if>
			<br>
			
			<b class="guianceBlock">Type of guidance:</b>
			<select id="guidanceTypeSelect" onchange="document.getElementById('guidanceType').value = document.getElementById('guidanceTypeSelect').value">
				<option value="-1">No guidance</option>
				<option value="performance">Performance</option>
				<option value="flexibility">Flexibility</option>
				<option value="customization">Customization</option>
			</select>
			
		</#if>
		</#compress>
<br/><br/>
		<table class="standardTableStyle">
		<tr>
			<th>#</th>
			<th><#if sortBy!='name'><a href="javascript:sortModels('name');">Name</a><#else><span class="standardHighlight1">Name</a></#if></TH>
			<th><#if sortBy!='features'><a href="javascript:sortModels('features');">Variants</a><#else><span class="standardHighlight1">Variants</a></#if></TH>
			<th><#if sortBy!='creator'><a href="javascript:sortModels('creator');">Creator</a><#else><span class="standardHighlight1">Creator</a></#if></TH>
			<th>Creation Date</th>
			
		</tr>
		<#list models as model>
		<tr onmouseover="this.className='highlightFMRepositoryEntry';" onmouseout="this.className='standardTableStyle';">
			<td>${model_index+1}.</td>
			<TD>
			<#if enableSelection><input class="standardHighlight1" <#if selectionMode="multiple"> type="checkbox"  <#elseif selectionMode="single"> type="radio" </#if> name="selectedModels" value="${model.file}"/></#if>${model.name}
			</td>
			<TD>${model.features}</td>
			
			<TD>${model.creator}&nbsp;</td>
			<TD>${model.date}&nbsp;</td>
			
		</tr>
		</#list>
		</table>
		<#if enableSelection>
			</form>
		</#if>
	</div>
</#if>
