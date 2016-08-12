package enterprises.stimes.pricefinding.scraping;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URL;
import java.nio.charset.Charset;

import org.json.JSONObject;
import org.json.JSONException;

public class ScrapeUtils {
	
	public static JSONObject readJsonFromUrl(String url) {
	    JSONObject json = null;
	    InputStream is = null;
	    try {
	    	is = new URL(url).openStream();
	    	BufferedReader rd = new BufferedReader(new InputStreamReader(is, Charset.forName("UTF-8")));
	    	String jsonText = readAll(rd);
	    	json = new JSONObject(jsonText);
	    	is.close();
	    } 
	    catch(IOException e){
	    	e.printStackTrace();
	    }
	    catch(JSONException e){
	    	e.printStackTrace();
	    }
	    return json;
	}
	
	private static String readAll(Reader rd) throws IOException {
		StringBuilder sb = new StringBuilder();
	    int cp;
	    while ((cp = rd.read()) != -1) {
	    	sb.append((char) cp);
	    }
	    return sb.toString();
	}
}
