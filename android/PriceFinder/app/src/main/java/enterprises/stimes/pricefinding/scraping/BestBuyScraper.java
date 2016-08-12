package enterprises.stimes.pricefinding.scraping;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;

public class BestBuyScraper extends Scraper {
	
	private String apiKey = Config.bestBuyApiKey;
	private String url = "http://api.bestbuy.com/v1/products";
			//+ "(name=castlevania*)?";//;apiKey=qt6ty86ctjj5f74s8gsnp4yn&format=json";
	
	private String apiKeyParam = "apiKey";
	//private String queryParam = "name";
	
	public BestBuyScraper(){
		super("BestBuy");
	}

	public ArrayList<ScrapingItem> search(String keyword)  {
		this.keywords = keyword;
		try {
			String query = String.format("(%s)?%s=%s", 
				 
			     //queryParam,
			     URLEncoder.encode(getSearchText(), charset),
					apiKeyParam,
				     URLEncoder.encode(this.apiKey, charset) 
			     );
			
			
			String queryUrl = url + query + "&format=json";
			System.out.println(queryUrl);
			JSONObject json = ScrapeUtils.readJsonFromUrl(queryUrl);

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
	
	private String getSearchText(){
		String toReturn = "";
		String[] keywrds = keywords.split(" ");
		boolean amp = false;
		for(String keyword : keywrds) {
			if(amp){
				toReturn += "&";
			}
			toReturn += "search=" + keyword;
			
			amp = true;
		}
		return toReturn;
	}
	
}
