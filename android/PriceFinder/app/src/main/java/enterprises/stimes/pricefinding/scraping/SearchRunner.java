package enterprises.stimes.pricefinding.scraping;

import android.os.AsyncTask;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import enterprises.stimes.pricefinder.models.Item;

/**
 * Created by Jacob on 7/16/2016
 */
public class SearchRunner {

    public interface SearchRunnerResultHandler {
        void searchFinished(ArrayList<Item> items);
    }

    public static void Search(String query, SearchRunnerResultHandler handler){
        SearchRunnerAsyncTask task = new SearchRunnerAsyncTask(handler);
        task.execute(query);
    }

    static class SearchRunnerAsyncTask extends AsyncTask<String, Void, ArrayList<Item>> {

        private SearchRunnerResultHandler handler;

        SearchRunnerAsyncTask(SearchRunnerResultHandler aHandler){
            handler = aHandler;
        }

        protected ArrayList<Item> doInBackground(String... queries){
            List<Scraper> scrapers = getAllScraperInstances();

            String query = queries[0];

            ArrayList<Scraper.ScrapingItem> allresults = new ArrayList<Scraper.ScrapingItem>();
            for(Scraper scraper : scrapers){
                allresults.addAll(scraper.search(query));
            }

            Collections.sort(allresults, new ItemComparator(query));

            ArrayList<Item> items = new ArrayList<Item>();
            for(Scraper.ScrapingItem item : allresults){
                System.out.println(item.salePrice + " " + item.name);

                items.add(new Item(item.name, item.site, item.description, item.salePrice));
            }

            return items;
        }

        protected void onPostExecute(ArrayList<Item> results){
            handler.searchFinished(results);
        }
    }

    private static ArrayList<Scraper> getAllScraperInstances() {
        ArrayList<Scraper> scrapers = new ArrayList<Scraper>();
        scrapers.add(new WalmartScraper());
        scrapers.add(new AmazonScraper());
        scrapers.add(new BestBuyScraper());

        return scrapers;
    }
}
