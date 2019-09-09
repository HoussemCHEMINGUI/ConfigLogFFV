package splot.configlog.models;

import splar.core.fm.FeatureGroup;
import splar.core.fm.FeatureTreeNode;
import splar.core.fm.GroupedFeature;
import splar.core.fm.SolitaireFeature;

/***
 * This class is created to save the trace of the configuration steps in order to enable a process mining analysis
 * FIXME: complete the remaining documentation
 * @author test
 *
 */

public class ConfigurationTrace {
	private String logFeatureId;
	private String logTimestamp;
	private FeatureTreeNode featureNode;
	private String logFeatureName;
	private int logFeatureVale;
	private String logDecisionType;
	private String logDecisionStep;
	private String logFeatureType;
	
	
	public ConfigurationTrace(FeatureTreeNode featureNode) {
		super();
		this.featureNode = featureNode;
		
		//I copy all values from the featureNode to save a "screen shot" of the current node state
		this.logFeatureName= getName();
		this.logFeatureVale =getValue();
		this.logDecisionType =getDecisionType();
		this.logDecisionStep =getDecisionStep();
		this.logFeatureType =getType();
		this.logTimestamp = getTimeStamp();
		this.logFeatureId= featureNode.getID();
		
	}

	public String getName() {
		if ( featureNode instanceof FeatureGroup ) {
			int min = ((FeatureGroup)featureNode).getMin();
			int max = ((FeatureGroup)featureNode).getMax();
			max = ( max==-1 ) ? featureNode.getChildCount() : max; 
			return "[" + min + ".." + max +"]";
		}
		return featureNode.getName();
	}

	public String getType() {
		if ( featureNode.isRoot() ) { 
			return "templateModel";				
		}
		else if ( featureNode instanceof SolitaireFeature) {
			if (((SolitaireFeature)featureNode).isOptional()) {
				return "optional";
			}
			else {
				return "mandatory";
			}
		}
		else if ( featureNode instanceof FeatureGroup ){
			return "group";
		}
		else if ( featureNode instanceof GroupedFeature ){
			return "grouped";
		}
		return "error";	
	}


	private String getDecisionType() {	
		return featureNode.getValue() == -1 ? "" : (String)featureNode.getProperty("decisionType");
	}

	private String getDecisionStep() {
		return featureNode.getValue() == -1 ? "" : (String)featureNode.getProperty("decisionStep");
	}


	private String getTimeStamp() {
		return featureNode.getProperty("timeStamp") == null ? "None": (String)featureNode.getProperty("timeStamp");
	}


	private int getValue() {
		return featureNode.getValue();
	}

	
	public String getLogFeatureId() {
		return logFeatureId;
	}

	public String getLogTimestamp() {
		return logTimestamp;
	}

	public FeatureTreeNode getFeatureNode() {
		return featureNode;
	}

	public String getLogFeatureName() {
		return logFeatureName;
	}

	public int getLogFeatureVale() {
		return logFeatureVale;
	}

	public String getLogDecisionType() {
		return logDecisionType;
	}

	public String getLogDecisionStep() {
		return logDecisionStep;
	}

	public String getLogFeatureType() {
		return logFeatureType;
	}
	
	@Override
	public String toString() {
		return "ConfigurationTrace [timestamp=" + logTimestamp + ", logFeatureName=" + logFeatureName + "value= "+ featureNode.getValue()+ "step: "+ logDecisionStep +"]";
	}
	

}
