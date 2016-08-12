package enterprises.stimes.pricefinding.scraping;

import java.util.Comparator;

import enterprises.stimes.pricefinding.scraping.Scraper.ScrapingItem;

public class ItemComparator implements Comparator<ScrapingItem> {

	private String keyword;
	
	private final int WORD_WEIGHT = 10;

	ItemComparator(String keyword){
		this.keyword = keyword.toLowerCase();
	}
	
	@Override
	public int compare(ScrapingItem o1, ScrapingItem o2) {
		
		//Save to only calculate once
		if(o1.editDistance == -1){
			o1.editDistance = editDistance(keyword, o1.name.toLowerCase());
		}
		if(o2.editDistance == -1){
			o2.editDistance = editDistance(keyword, o2.name.toLowerCase());
		}
		
		//Positive number means o1 is more expensive
		double price = o1.salePrice - o2.salePrice;
		
		//Positive number means o1 is further away from title than o2
		int words = o1.editDistance - o2.editDistance;
		
		return ((int)price) + (WORD_WEIGHT*words);
	}

	public static int editDistance(String word1, String word2) {
		int len1 = word1.length();
		int len2 = word2.length();
	 
		// len1+1, len2+1, because finally return dp[len1][len2]
		int[][] dp = new int[len1 + 1][len2 + 1];
	 
		for (int i = 0; i <= len1; i++) {
			dp[i][0] = i;
		}
	 
		for (int j = 0; j <= len2; j++) {
			dp[0][j] = j;
		}
	 
		//iterate though, and check last char
		for (int i = 0; i < len1; i++) {
			char c1 = word1.charAt(i);
			for (int j = 0; j < len2; j++) {
				char c2 = word2.charAt(j);
	 
				//if last two chars equal
				if (c1 == c2) {
					//update dp value for +1 length
					dp[i + 1][j + 1] = dp[i][j];
				} else {
					int replace = dp[i][j] + 1;
					int insert = dp[i][j + 1] + 1;
					int delete = dp[i + 1][j] + 1;
	 
					int min = replace > insert ? insert : replace;
					min = delete > min ? min : delete;
					dp[i + 1][j + 1] = min;
				}
			}
		}
	 
		return dp[len1][len2];
	}
}