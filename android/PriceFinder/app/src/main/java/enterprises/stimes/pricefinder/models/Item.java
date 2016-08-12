package enterprises.stimes.pricefinder.models;

/**
 * Created by Jacob on 6/3/2016.
 */
public class Item {

    public String title;
    public String vendor;
    public String description;
    public double price;

    //For search fragment:
    public Boolean selected = false;

    public Item(String title, String vendor, String description, double price){
        this.title = title;
        this.vendor = vendor;
        this.description = description;
        this.price = price;
    }

    public void setSelected(Boolean selected){
        this.selected = selected;
    }

    public static Item[] getTestItems() {
        return new Item[] {
                new Item("Mariokart", "walmart", "a fun game", 45.00),
                new Item("Macbook air", "best buy", "good book", 745.00),
                new Item("MacBook Pro", "amazon", "a better book", 845.00),
                new Item("Mariokart", "walmart", "a fun game", 45.00),
                new Item("Macbook air", "best buy", "good book", 745.00),
                new Item("MacBook Pro", "amazon", "a better book", 845.00),
                new Item("Mariokart", "walmart", "a fun game", 45.00),
                new Item("Macbook air", "best buy", "good book", 745.00),
                new Item("MacBook Pro", "amazon", "a better book", 845.00)
        };
    }
}
