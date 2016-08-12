package enterprises.stimes.pricefinding.scraping;

import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONArray;

import java.util.ArrayList;

public abstract class Scraper {
	
	protected String site;
	protected String keywords;
	
	protected final String charset = "UTF-8";
	
	public Scraper(String site){
		this.site = site;
	}
	
	public abstract ArrayList<ScrapingItem> search(String keywords);
	
	protected ArrayList<ScrapingItem> getItemsFromSearch(JSONObject json) throws JSONException {
		String itemsNode = "items";
		if(this.site.equals("BestBuy")){
			itemsNode = "products";
		}
		ArrayList<ScrapingItem> items = new ArrayList<>();
		JSONArray itemsArr = (JSONArray) json.get(itemsNode);
		
		for(int i=0; i<itemsArr.length(); i++){
			JSONObject item = (JSONObject) itemsArr.get(i);
			items.add(new ScrapingItem(item, this.site));
		}
		
		return items;
	}

	class ScrapingItem {
		String name;
		double salePrice;
		double regularPrice;
		boolean sale;
		String description;
		long itemId;
		String site;
		int editDistance = -1;

		ScrapingItem(JSONObject json, String site) throws JSONException {
			this.name = json.getString("name");
			this.salePrice = json.getDouble("salePrice");
			
//			if(json.get("regularPrice") != null){
//				this.regularPrice = json.getDouble("regularPrice");
//			}
			
			//this.sale = (boolean) json.get("onSale");
			//this.description = json.getString("shortDescription");

			try {
				if (json.get("productId") != null) {
					this.itemId = json.getLong("productId");
				} else {
					this.itemId = json.getLong("itemId");
				}
			}
			catch(Exception e){
				//TODO
			}
			this.site = site;
		}

		ScrapingItem(String title, double price){
			this.name = title;
			this.salePrice = price;
		}
	}
}
