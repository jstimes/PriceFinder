package enterprises.stimes.pricefinding.scraping;

import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class AmazonScraper extends Scraper {
	
	/*
     * Your AWS Access Key ID, as taken from the AWS Your Account page.
     */
    private static final String AWS_ACCESS_KEY_ID = Config.amazonAccessKey;

    /*
     * Your AWS Secret Key corresponding to the above ID, as taken from the AWS
     * Your Account page.
     */
    private static final String AWS_SECRET_KEY = Config.amazonSecretKey;

    /*
     * Use one of the following end-points, according to the region you are
     * interested in:
     * 
     *      US: ecs.amazonaws.com 
     *      CA: ecs.amazonaws.ca 
     *      UK: ecs.amazonaws.co.uk 
     *      DE: ecs.amazonaws.de 
     *      FR: ecs.amazonaws.fr 
     *      JP: ecs.amazonaws.jp
     * 
     */
    private static final String ENDPOINT = "webservices.amazon.com";//"ecs.amazonaws.com";
	
	public AmazonScraper(){
		super("Amazon");
	}
	
	public ArrayList<ScrapingItem> search(String keywords) {
		/*
         * Set up the signed requests helper 
         */
        SignedRequestsHelper helper;
        try {
            helper = SignedRequestsHelper.getInstance(ENDPOINT, AWS_ACCESS_KEY_ID, AWS_SECRET_KEY);
        } 
        catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<ScrapingItem>();
        }
        
		this.keywords = keywords;
		Map<String, String> params = new HashMap<String, String>();
        params.put("Service", "AWSECommerceService");
        params.put("Keywords", this.keywords);
        params.put("Operation", "ItemSearch");
        params.put("SearchIndex", "Blended");
        params.put("ResponseGroup", "ItemAttributes");
        params.put("AssociateTag", "pricfind00-20");

        String requestUrl = helper.sign(params);
        Log.i("finding", "Amazon");
        Log.i("finding", requestUrl);

        return fetchTitle(requestUrl);
    }

    /*
     * Utility function to fetch the response from the service and extract the
     * title from the XML.
     */
    private ArrayList<ScrapingItem> fetchTitle(String requestUrl) {
        ArrayList<ScrapingItem> itemsList = new ArrayList<ScrapingItem>();
        try {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            DocumentBuilder db = dbf.newDocumentBuilder();
            Document doc = db.parse(requestUrl);
            NodeList items = doc.getElementsByTagName("ItemAttributes");//.item(0);
            
            for(int i=0; i<items.getLength(); i++){
            	Node item = items.item(i);
            	Node child = item.getFirstChild();
            	String title = "";
            	double amount = -1.00;
    			while(child != null){
    				
    				if(child.getNodeName().equals("Title")){
    					title = child.getTextContent();
    				}
    				else if(child.getNodeName().equals("ListPrice")){
    					Node priceChild = child.getFirstChild();
    					while(priceChild !=null){
    						if(priceChild.getNodeName().equals("Amount")){
    							amount = Double.parseDouble(priceChild.getTextContent());
    						}
    						priceChild = priceChild.getNextSibling();
    					}
    				}
    				child = child.getNextSibling();
    			}
    			if(title.length() > 0 && amount > 0.0){
    				itemsList.add(new ScrapingItem(title, amount / 100.0f));
    			}
            }
           // title = titleNode.getTextContent();
        } catch (Exception e) {
           // throw new RuntimeException(e);
            e.printStackTrace();
            return new ArrayList<>();
        }
        return itemsList;
    }
}
