package enterprises.stimes.pricefinder.models;

import java.util.ArrayList;

/**
 * Created by Jacob on 6/4/2016.
 */
public class HomeItem {

    public long groupId;
    public String title;
    public double targetPrice;
    public double lowestPrice;
    public boolean foundTarget;
    public ArrayList<Item> items = new ArrayList<Item>();

    //date added

    public HomeItem(long groupId, String title, double target, Item[] items){
        this.groupId = groupId;
        this.title = title;
        this.targetPrice = target;

        for(Item item : items){
            this.items.add(item);
        }

        findLowestAndTarget();
    }

    public HomeItem(long groupId, String title, double target, ArrayList<Item> items){
        this.groupId = groupId;
        this.title = title;
        this.targetPrice = target;
        this.items.addAll(items);

        findLowestAndTarget();
    }

    private void findLowestAndTarget(){
        lowestPrice = 1000000.0;
        for(int i=0; i<items.size(); i++){
            Item itemI = items.get(i);
            if(itemI.price < lowestPrice){
                lowestPrice = itemI.price;
            }
        }
        if(lowestPrice < targetPrice){
            foundTarget = true;
        }
    }
}
