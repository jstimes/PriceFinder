package enterprises.stimes.pricefinding.scraping;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;

import org.json.JSONException;
import org.json.JSONObject;

public class WalmartScraper extends Scraper {
	
	private String searchUrl = "http://api.walmartlabs.com/v1/search?";

	private String apiKeyParam = "apiKey";
	private String queryParam = "query";
	private String apiKey = Config.walmartApiKey;
	
	public WalmartScraper(){
		super("Walmart");
	}
	
	public ArrayList<ScrapingItem> search(String queryString) {
		this.keywords = queryString;
		try {
			String query = String.format("%s=%s&%s=%s", 
				 apiKeyParam,
			     URLEncoder.encode(this.apiKey, charset), 
			     queryParam,
			     URLEncoder.encode(this.keywords, charset));
			
			String queryUrl = searchUrl + query;
			System.out.println(queryUrl);
			JSONObject json = ScrapeUtils.readJsonFromUrl(queryUrl);
			//System.out.println("NumItems: " + Long.toString((long)json.get("numItems")));
			return super.getItemsFromSearch(json);
		} 
		catch (UnsupportedEncodingException e1) {
			e1.printStackTrace();
			return new ArrayList<ScrapingItem>();
		}
		catch(JSONException e){
			e.printStackTrace();
			return new ArrayList<>();
		}
	}

}
