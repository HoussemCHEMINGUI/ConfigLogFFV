package splot.services.handlers.conf;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.sun.corba.se.impl.orbutil.graph.Node;

import freemarker.template.Configuration;
import freemarker.template.Template;
import splar.core.fm.FeatureGroup;
import splar.core.fm.FeatureTreeNode;
import splar.core.fm.GroupedFeature;
import splar.core.fm.SolitaireFeature;
import splar.core.fm.configuration.ConfigurationEngine;
import splar.core.fm.configuration.ConfigurationStep;
import splot.configlog.models.ConfigurationTrace;
import splot.core.FreeMarkerHandler;
import splot.core.HandlerExecutionException;

public class SATInteractiveConfigurationUpdatesHandler extends FreeMarkerHandler {

	protected InteractiveConfigurationElementsProducer confElementProducer = null;

	public SATInteractiveConfigurationUpdatesHandler(String handlerName, HttpServlet servlet, Configuration configuration, Template template) {
		super(handlerName, servlet, configuration, template);
	}
	
	@Override
	public void setResponseParameters(HttpServletResponse response) {
		response.setContentType("text/xml; charset=" + template.getEncoding());
	}
	
	public void buildModel(HttpServletRequest request, HttpServletResponse response, Map templateModel) throws HandlerExecutionException {

		try {
	        String op = (String)request.getParameter("op"); 
	        //NEW
	        String timeStamp = (String)request.getParameter("timeStamp"); 
	        if ( op == null) {
	        	throw new HandlerExecutionException("Paremeter 'op' is missing");
	        }
			
	        //Mod for having the timestamp
        	HttpSession session = request.getSession(true);        	
        	ConfigurationEngine confEngine = (ConfigurationEngine)session.getAttribute("conf_engine");	        		
    		
    		if (confEngine == null) {
    			throw new HandlerExecutionException("Configuration engine must be created first");
    		}
    		
    		List<ConfigurationStep> stepsToUpdateList = null;
    		Set<FeatureTreeNode> additionalFeatures = null;
    		
    		/*********************************************************************
    		 * UNDO configuration step
    		 *********************************************************************/
        	if ( op.compareToIgnoreCase("undo") == 0 ) {
        		
        		stepsToUpdateList = confEngine.undo(Integer.valueOf(request.getParameter("step")));
        		templateModel.put("countUndoSteps", stepsToUpdateList.size());
    			
        	}
    		/*********************************************************************
    		 * AUTO-COMPLETE configuration
    		 *********************************************************************/
        	else if ( op.compareToIgnoreCase("completion") == 0 ) {

        		boolean valueOrder = false;  // if false (default): false,true ; if true: true,false
        		try {
        			valueOrder = Boolean.valueOf(request.getParameter("precedence"));        			
        		}
        		catch(Exception e) {}
        		
        		stepsToUpdateList = new LinkedList<ConfigurationStep>();
        		stepsToUpdateList.add( confEngine.autoComplete(valueOrder) );
        		
        	}
    		/*********************************************************************
    		 * CONFIGURATION step
    		 *********************************************************************/
        	else if ( op.compareToIgnoreCase("conf") == 0 ) {

        		// Recover decision details: featureid and assignment value
        		String decisionVar = request.getParameter("decision").split(":")[0];
        		String decisionValue = request.getParameter("decision").split(":")[1];  // 0=false, 1=true
        		
        		if ( decisionVar == null || decisionValue == null ) {
        			throw new HandlerExecutionException("Configuration step requires specifying a feature ID and a value to be assigned");
        		}
        		
        		stepsToUpdateList = new LinkedList<ConfigurationStep>();
        		ConfigurationStep configurationStep= confEngine.configure(decisionVar, decisionValue.equals("1") ? 1 : 0); 
        		stepsToUpdateList.add(configurationStep);
        		
        		// CONFIGLOG: Added to keep track of the configuration actions
        		this.saveTraceLog(session,confEngine,configurationStep, timeStamp);
        		
 
        	}
    		/*********************************************************************
    		 * TOGGLE feature value
    		 *********************************************************************/
        	else if ( op.compareToIgnoreCase("toggle") == 0 ) {
            	String toggleFeature = (String)request.getParameter("toggleFeature");          		
        		if (toggleFeature == null) {
        			throw new HandlerExecutionException("Toggle feature must be specified");
        		}
        		FeatureTreeNode toggleFeatureNode = confEngine.getModel().getNodeByID(toggleFeature);
        		if ( toggleFeatureNode == null ) {
        			throw new HandlerExecutionException("Toggle feature Id is invalid");
        		}
        		
        		int toggleFeatureStep = Integer.valueOf((String)toggleFeatureNode.getProperty("decisionStep"));        		
        		int countUndoSteps = confEngine.getSteps().size() - toggleFeatureStep + 1;

        		// save relevant propagated features before toggling
        		additionalFeatures = new HashSet<FeatureTreeNode>();
        		for( int i = toggleFeatureStep-1 ;  i < confEngine.getSteps().size() ; i++ ) {
        			additionalFeatures.addAll(confEngine.getSteps().get(i).getPropagations() );
        		}
        		
        		// toggle decision and grabs new steps
        		stepsToUpdateList = confEngine.toggleDecision(toggleFeature);
        		
        		// CONFIGLOG: Added to keep track of the configuration actions
        		System.out.println("CONFIGLOG: toggle feature calling the log saver");
        		//Only the first value because it is the step that was changed with the toggle action
            	this.saveTraceLog(session,confEngine,stepsToUpdateList.get(0), timeStamp);
        		
        		templateModel.put("countUndoSteps", countUndoSteps);
        		
        	}
        	else {
        		throw new HandlerExecutionException("Invalid 'op' parameter: " + op);
        	}
        	
        	// Creates producer of HTML updates for features and configuration steps  
        	if ( confElementProducer == null ) {
        		confElementProducer = new InteractiveConfigurationElementsProducer(getTemplateConfiguration());
        	}
        	
        	if ( !op.equals("undo") ) {
	        	// Traverses steps and identify several related parameters
	        	List<Map> stepsList = new LinkedList<Map>();
	        	for( ConfigurationStep step : stepsToUpdateList ) {
	        		Map stepData = new HashMap();
	    			String stepElementData = confElementProducer.produceStepElement(step, stepData);
	        		stepData.put("configurationStepElement", stepElementData);
	        		stepsList.add(stepData);
	        	}
	        	templateModel.put("steps", stepsList);
        	}
        	
        	
        	List<Map> featuresList = new LinkedList<Map>();		    		
        	for( ConfigurationStep confStepObj : stepsToUpdateList ) {
        		Set<FeatureTreeNode> stepFeatures = new HashSet<FeatureTreeNode>();
        		stepFeatures.addAll(confStepObj.getDecisions());	        			        	
        		stepFeatures.addAll(confStepObj.getPropagations());	        			        	
	    		for( FeatureTreeNode feature : stepFeatures ) {
	    			
	    			if ( additionalFeatures != null && additionalFeatures.contains(feature) ) {
    					additionalFeatures.remove(feature);
	    			}
	    			Map featureData = new HashMap();
	    			//featureData.put("feature_timestamp", timeStamp);
	    			String featureElementData = confElementProducer.produceFeatureElement(feature, featureData, SATInteractiveConfigurationMainHandler.featureTemplateFilename);
	    			featureData.put("configurationFeatureElement", featureElementData);
	    			featuresList.add(featureData);
	    		}
        	}
        	
        	if ( additionalFeatures != null ) {
	    		for( FeatureTreeNode feature : additionalFeatures ) {
	    			Map featureData = new HashMap();
	    			// NEW x houss
	    			feature.setProperty("timeStamp", timeStamp);
	    			String featureElementData = confElementProducer.produceFeatureElement(feature, featureData, SATInteractiveConfigurationMainHandler.featureTemplateFilename);
	    			featureData.put("configurationFeatureElement", featureElementData);
	    			featuresList.add(featureData);
	    		}
        	}
        	
        	templateModel.put("countFeatures", confEngine.getModel().countFeatures());
        	templateModel.put("countInstantiatedFeatures", confEngine.getModel().getInstantiatedNodes().size());
        	templateModel.put("op", op);
    		templateModel.put("features", featuresList);
			templateModel.put("done", confEngine.isDone());
        	
		} catch (Exception e) {
			e.printStackTrace();
			throw new HandlerExecutionException("Problem updating configuration", e);
		}
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
			return "root";				
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
	
	
	private void saveTraceLog(HttpSession session, ConfigurationEngine confEngine, ConfigurationStep step, String timeStamp) {
		/* Try to keep the trace from the session, if the list does not exist then it creates the list and save
		 * it in the session. Then it adds a new ConfigurationTrace object into the list, and update the list into the 
		 * session variable. This variable will be later checked to export the results in the handler that export the csv files. 
		 * Author: Luisa 
		 */     	

		//Get the list of traces from  the session variable
		List<ConfigurationTrace> listOfConfigTraces= (List<ConfigurationTrace>) session.getAttribute("configurationLogs");
    	if (listOfConfigTraces == null) {
    		// TO avoid null pointer exceptions
    		listOfConfigTraces= new ArrayList<ConfigurationTrace> ();
    	}
    	
    	//MODIFY  changed for keeping log for the ConfigLog project
		Set<FeatureTreeNode> lastDecisions = step.getDecisions();
		Set<FeatureTreeNode> lastPropagations = step.getPropagations();
		Collection<FeatureTreeNode>modelNodes= confEngine.getModel().getNodes();
		
		for (FeatureTreeNode featureNode: modelNodes) {
			if(featureNode.isInstantiated() && (lastDecisions.contains(featureNode)||lastPropagations.contains(featureNode)) ){
				// For future information we add the timestamp to the feature
				featureNode.setProperty("timeStamp", timeStamp);
				
				// A new configuration trace object is created to keep all info
				ConfigurationTrace trace= new ConfigurationTrace(featureNode);
				listOfConfigTraces.add(trace);
				
				System.out.println("CONFLOG: saving configuration trace  "+ trace);
			}
		}
    	
    	//Update the list of traces into the session to be able of recovering this variable in the handler that exports the content
    	session.setAttribute("configurationLogs", listOfConfigTraces );
    	
    	System.out.println("CONFLOG: updating logs into session variable  ");
    	
    	
	}
}



