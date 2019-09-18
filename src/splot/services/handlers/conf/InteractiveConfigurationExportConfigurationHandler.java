package splot.services.handlers.conf;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.time.LocalTime;
import java.util.Calendar;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import freemarker.template.Configuration;
import freemarker.template.Template;
import splar.core.fm.FeatureGroup;
import splar.core.fm.FeatureModel;
import splar.core.fm.FeatureTreeNode;
import splar.core.fm.GroupedFeature;
import splar.core.fm.SolitaireFeature;
import splar.core.fm.configuration.ConfigurationEngine;
import splot.configlog.models.ConfigurationTrace;
import splot.core.FreeMarkerHandler;
import splot.core.HandlerExecutionException;

public class InteractiveConfigurationExportConfigurationHandler extends FreeMarkerHandler {

	public InteractiveConfigurationExportConfigurationHandler(String handlerName, HttpServlet servlet, Configuration configuration, Template template) {
		super(handlerName, servlet, configuration, template);
	}
	
	public void buildModel(HttpServletRequest request, HttpServletResponse response, Map templateModel) throws HandlerExecutionException {

        try {	        		        	
        	HttpSession session = request.getSession(true);	        	

        	ConfigurationEngine confEngine = (ConfigurationEngine)session.getAttribute("conf_engine");
        	FeatureModel model = confEngine.getModel();
        	Calendar cal = Calendar.getInstance();
            SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
            sdf.format(cal.getTime());
    		if (confEngine == null) {
    			throw new HandlerExecutionException("Configuration engine must be created first");
    		}
        	
    		String uniqueID = UUID.randomUUID().toString().replace("-", "").substring(0,6);

    		templateModel.put("id", uniqueID);
        	templateModel.put("modelName", model.getName());
        	templateModel.put("originatorName", request.getParameter("originatorName"));

/*        	List features = new LinkedList();
        	for( FeatureTreeNode featureNode : model.getNodes() ) {
        		if ( featureNode.isInstantiated() ) {
	        		Map featureData = new HashMap();
	    			featureData.put("id", featureNode.getID());
	    			featureData.put("name", getFeatureName(featureNode));
	    			featureData.put("type", getFeatureType(featureNode));
	    			featureData.put("value", ""+featureNode.getValue());
	    			featureData.put("decisionType", featureNode.getValue() == -1 ? "" : (String)featureNode.getProperty("decisionType"));   // manual, propagated, auto-completion
	    			featureData.put("decisionStep", featureNode.getValue() == -1 ? "" : (String)featureNode.getProperty("decisionStep"));   
	    			//featureData.put("timestamp", sdf.format(cal.getTime()));
	    			//  NEW
	    			featureData.put("timeStamp",  featureNode.getProperty("timeStamp") == null ? "None" :featureNode.getProperty("timeStamp"));
	    			features.add(featureData);
        		}
        	}*/
        	List<Object> features = getConfigurationTraceToExport(session);
        	templateModel.put("features", features);
        	
	        	
		} catch (Exception e) {
			e.printStackTrace();
			throw new HandlerExecutionException("Configuration engine must be created first", e);
		}
	}
 protected LocalTime getFeatureTime( FeatureTreeNode feature ) {
		
	return LocalTime.now();
	}
	
	
	protected String getFeatureParent(FeatureTreeNode feature) {
		FeatureTreeNode parent = (FeatureTreeNode)feature.getParent();
		if ( parent == null ) {
			return "";
		}
		return parent.getID();		
	}
	
	protected String getFeatureName( FeatureTreeNode feature ) {
		if ( feature instanceof FeatureGroup ) {
			int min = ((FeatureGroup)feature).getMin();
			int max = ((FeatureGroup)feature).getMax();
			max = ( max==-1 ) ? feature.getChildCount() : max; 
			return "[" + min + ".." + max +"]";
		}
		return feature.getName();
	}
	
	protected String getFeatureType( FeatureTreeNode feature ) {
		if ( feature.isRoot() ) { 
			return "templateModel";				
		}
		else if ( feature instanceof SolitaireFeature) {
			if (((SolitaireFeature)feature).isOptional()) {
				return "optional";
			}
			else {
				return "mandatory";
			}
		}
		else if ( feature instanceof FeatureGroup ){
			return "group";
		}
		else if ( feature instanceof GroupedFeature ){
			return "grouped";
		}
		return "error";
	}	
	
	
	/**
	 * ConfigLog method to show the configuration traces
	 * @param session
	 * @return
	 * @throws HandlerExecutionException
	 */
	private List<Object> getConfigurationTraceToExport(HttpSession session) throws HandlerExecutionException {
		//Get the list of traces from  the session variable
		List<ConfigurationTrace> listOfConfigTraces= (List<ConfigurationTrace>) session.getAttribute("configurationLogs");
		if (listOfConfigTraces == null) {
			throw new HandlerExecutionException("ConfigLog error: Configuration traces were not saved");
		}
		
		List<Object> features = new LinkedList<Object> ();
    	for( ConfigurationTrace configTrace : listOfConfigTraces ) {
    		Map <String,Object> featureData = new HashMap();
			featureData.put("id", configTrace.getLogFeatureId());
			featureData.put("name", configTrace.getLogFeatureName());
			featureData.put("type", configTrace.getLogFeatureType());
			featureData.put("value", configTrace.getLogFeatureVale());
			featureData.put("decisionType",configTrace.getLogDecisionType() );   // manual, propagated, auto-completion
			featureData.put("decisionStep", configTrace.getLogDecisionStep());   
			featureData.put("timeStamp",  configTrace.getLogTimestamp());
			features.add(featureData);
    	}
    	return features;
	}
}

