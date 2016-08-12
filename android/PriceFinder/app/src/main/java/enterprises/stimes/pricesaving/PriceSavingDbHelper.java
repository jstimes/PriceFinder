package enterprises.stimes.pricesaving;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

import java.util.ArrayList;

import enterprises.stimes.pricefinder.models.Item;
import enterprises.stimes.pricefinder.models.HomeItem;

/**
 * Provides functions for interacting with database
 * Created by Jacob on 7/16/2016.
 */
public class PriceSavingDbHelper extends SQLiteOpenHelper {

    //TO ACCESS: FeedReaderDbHelper mDbHelper = new FeedReaderDbHelper(getContext());

    private static final String TEXT_TYPE = " TEXT";
    private static final String REAL_TYPE = " REAL";
    private static final String LONG_TYPE = " LONG";
    private static final String COMMA_SEP = ",";

    private static final String SQL_CREATE_GROUPS =
            "CREATE TABLE " + PriceFinderContract.SavedItemGroups.TABLE_NAME + " (" +
                    PriceFinderContract.SavedItemGroups._ID + " INTEGER PRIMARY KEY," +
                    PriceFinderContract.SavedItemGroups.COLUMN_NAME_SEARCH_TEXT + TEXT_TYPE + COMMA_SEP +
                    PriceFinderContract.SavedItemGroups.COLUMN_NAME_TARGET_PRICE + REAL_TYPE +
            " )";

    private static final String SQL_CREATE_ITEMS =
            "CREATE TABLE " + PriceFinderContract.SavedItems.TABLE_NAME + " (" +
                    PriceFinderContract.SavedItems._ID + " INTEGER PRIMARY KEY," +
                    PriceFinderContract.SavedItems.COLUMN_NAME_GROUP_ID + LONG_TYPE + COMMA_SEP +
                    PriceFinderContract.SavedItems.COLUMN_NAME_TITLE + TEXT_TYPE + COMMA_SEP +
                    PriceFinderContract.SavedItems.COLUMN_NAME_PRICE + REAL_TYPE + COMMA_SEP +
                    PriceFinderContract.SavedItems.COLUMN_NAME_VENDOR + REAL_TYPE + COMMA_SEP +
                    PriceFinderContract.SavedItems.COLUMN_NAME_DESCRIPTION + TEXT_TYPE +
                    " )";

    private static final String SQL_DELETE_SAVED_ITEM_GROUPS =
            "DROP TABLE IF EXISTS " + PriceFinderContract.SavedItemGroups.TABLE_NAME;

    private static final String SQL_DELETE_SAVED_ITEMS =
            "DROP TABLE IF EXISTS " + PriceFinderContract.SavedItems.TABLE_NAME;

    // If you change the database schema, you must increment the database version.
    public static final int DATABASE_VERSION = 2;
    public static final String DATABASE_NAME = "PriceSaving.db";

    public PriceSavingDbHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    public void onCreate(SQLiteDatabase db) {
        db.execSQL(SQL_CREATE_GROUPS);
        db.execSQL(SQL_CREATE_ITEMS);
    }
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        // This database is only a cache for online data, so its upgrade policy is
        // to simply to discard the data and start over
        db.execSQL(SQL_DELETE_SAVED_ITEM_GROUPS);
        db.execSQL(SQL_DELETE_SAVED_ITEMS);

        onCreate(db);
    }
    public void onDowngrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        onUpgrade(db, oldVersion, newVersion);
    }

    public static void insert(Context cxt, String searchText, double targetPrice, ArrayList<Item> items){
       PriceSavingDbHelper mDbHelper = new PriceSavingDbHelper(cxt);
        // Gets the data repository in write mode
        SQLiteDatabase db = mDbHelper.getWritableDatabase();

        // Create a new map of values, where column names are the keys
        ContentValues values = new ContentValues();
        values.put(PriceFinderContract.SavedItemGroups.COLUMN_NAME_SEARCH_TEXT, searchText);
        values.put(PriceFinderContract.SavedItemGroups.COLUMN_NAME_TARGET_PRICE, targetPrice);

        // Insert the new row, returning the primary key value of the new row
        long groupId;
        groupId = db.insert(
                PriceFinderContract.SavedItemGroups.TABLE_NAME,
                null, // don't create row on empty insert... shouldn't happen
                values);

        Log.i("DB", "Inserted " + groupId + " groupId");


        //Insert items:
        addItemsToSearchGroup(cxt, groupId, items);
    }

    public static ArrayList<HomeItem> getHomeItems(Context cxt){

        PriceSavingDbHelper mDbHelper = new PriceSavingDbHelper(cxt);
        SQLiteDatabase db = mDbHelper.getReadableDatabase();

        // Define a projection that specifies which columns from the database
        // you will actually use after this query.
        String[] projection = {
                PriceFinderContract.SavedItemGroups._ID,
                PriceFinderContract.SavedItemGroups.COLUMN_NAME_SEARCH_TEXT,
                PriceFinderContract.SavedItemGroups.COLUMN_NAME_TARGET_PRICE,
        };

        // How you want the results sorted in the resulting Cursor
        //String sortOrder =
          //      PriceFinderContract.SavedItemGroups.COLUMN_NAME_DATE_ADDED + " DESC";

        Cursor cursor = db.query(
                PriceFinderContract.SavedItemGroups.TABLE_NAME,  // The table to query
                projection,                               // The columns to return
                null,//selection,                                // The columns for the WHERE clause
                null,//selectionArgs,                            // The values for the WHERE clause
                null,                                     // don't group the rows
                null,                                     // don't filter by row groups
                null//sortOrder                                 // The sort order
        );

        ArrayList<HomeItem> homeItems = new ArrayList<HomeItem>();
        cursor.moveToFirst();

        while(cursor.moveToNext()) {
            long groupId = cursor.getLong(
                    cursor.getColumnIndexOrThrow(PriceFinderContract.SavedItemGroups._ID)
            );

            double targetPrice = cursor.getDouble(
                    cursor.getColumnIndexOrThrow(PriceFinderContract.SavedItemGroups.COLUMN_NAME_TARGET_PRICE)
            );

            String searchText = cursor.getString(
                    cursor.getColumnIndexOrThrow(PriceFinderContract.SavedItemGroups.COLUMN_NAME_SEARCH_TEXT)
            );

            ArrayList<Item> items = getItemsForSavedGroupId(cxt, groupId);

            HomeItem homeItem = new HomeItem(groupId, searchText, targetPrice, items);
            homeItems.add(homeItem);
        }

        return homeItems;
    }

    public static ArrayList<Item> getItemsForSavedGroupId(Context cxt, long groupId){

        PriceSavingDbHelper mDbHelper = new PriceSavingDbHelper(cxt);
        SQLiteDatabase db = mDbHelper.getReadableDatabase();

        // Define a projection that specifies which columns from the database
        // you will actually use after this query.
        String[] projection = {
                PriceFinderContract.SavedItems._ID,
                PriceFinderContract.SavedItems.COLUMN_NAME_GROUP_ID,
                PriceFinderContract.SavedItems.COLUMN_NAME_PRICE,
                PriceFinderContract.SavedItems.COLUMN_NAME_TITLE,
                PriceFinderContract.SavedItems.COLUMN_NAME_VENDOR,
                PriceFinderContract.SavedItems.COLUMN_NAME_DESCRIPTION,
        };

        // How you want the results sorted in the resulting Cursor
        String sortOrder =
              PriceFinderContract.SavedItems.COLUMN_NAME_PRICE; // " ASC" ?

        Cursor cursor = db.query(
                PriceFinderContract.SavedItems.TABLE_NAME,  // The table to query
                projection,                               // The columns to return
                PriceFinderContract.SavedItems.COLUMN_NAME_GROUP_ID + " = '" + groupId + "'",//selection,                                // The columns for the WHERE clause
                null,//selectionArgs,                            // The values for the WHERE clause
                null,                                     // don't group the rows
                null,                                     // don't filter by row groups
                sortOrder                                 // The sort order
        );

        ArrayList<Item> items = new ArrayList<Item>();
        cursor.moveToFirst();

        while(cursor.moveToNext()) {
            long itemId = cursor.getLong(
                    cursor.getColumnIndexOrThrow(PriceFinderContract.SavedItems._ID)
            );

            double price = cursor.getDouble(
                    cursor.getColumnIndexOrThrow(PriceFinderContract.SavedItems.COLUMN_NAME_PRICE)
            );

            String title = cursor.getString(
                    cursor.getColumnIndexOrThrow(PriceFinderContract.SavedItems.COLUMN_NAME_TITLE)
            );

            String vendor = cursor.getString(
                    cursor.getColumnIndexOrThrow(PriceFinderContract.SavedItems.COLUMN_NAME_VENDOR)
            );

            String description = cursor.getString(
                    cursor.getColumnIndexOrThrow(PriceFinderContract.SavedItems.COLUMN_NAME_DESCRIPTION)
            );

            Item item = new Item(title, vendor, description, price);
            items.add(item);
        }

        Log.i("DB", "Read " + items.size() + " items");
        return items;
    }

    public static void updateTargetPriceForGroupId(Context cxt, long groupId, double newPrice){
        PriceSavingDbHelper mDbHelper = new PriceSavingDbHelper(cxt);
        SQLiteDatabase db = mDbHelper.getReadableDatabase();

        // New value for one column
        ContentValues values = new ContentValues();
        values.put(PriceFinderContract.SavedItemGroups.COLUMN_NAME_TARGET_PRICE, newPrice);

        // Which row to update, based on the ID
        String selection = PriceFinderContract.SavedItemGroups._ID + " LIKE ?";
        String[] selectionArgs = { String.valueOf(groupId) };

        int count = db.update(
                PriceFinderContract.SavedItemGroups.TABLE_NAME,
                values,
                selection,
                selectionArgs);
    }

    public static void addItemsToSearchGroup(Context cxt, long groupId, ArrayList<Item> newItems){
        PriceSavingDbHelper dbHelper = new PriceSavingDbHelper(cxt);
        SQLiteDatabase db = dbHelper.getReadableDatabase();

        for(Item item : newItems){
            // Create a new map of values, where column names are the keys
            ContentValues itemValues = new ContentValues();
            itemValues.put(PriceFinderContract.SavedItems.COLUMN_NAME_TITLE, item.title);
            itemValues.put(PriceFinderContract.SavedItems.COLUMN_NAME_PRICE, item.price);
            itemValues.put(PriceFinderContract.SavedItems.COLUMN_NAME_VENDOR, item.vendor);
            itemValues.put(PriceFinderContract.SavedItems.COLUMN_NAME_DESCRIPTION, item.description);
            itemValues.put(PriceFinderContract.SavedItems.COLUMN_NAME_GROUP_ID, groupId);


            // Insert the new row, returning the primary key value of the new row
            long itemNewRowId;
            itemNewRowId = db.insert(
                    PriceFinderContract.SavedItems.TABLE_NAME,
                    null, // don't create row on empty insert... shouldn't happen
                    itemValues);

            Log.i("DB", "Inserted an item groupId");
        }
    }

    public static void removeItemsFromGroup(Context cxt, long groupId, ArrayList<Item> itemsToRemove){
        PriceSavingDbHelper dbHelper = new PriceSavingDbHelper(cxt);
        SQLiteDatabase db = dbHelper.getWritableDatabase();

        // Define 'where' part of query.
        String selection = PriceFinderContract.SavedItems.COLUMN_NAME_GROUP_ID + " LIKE ?";

        // Specify arguments in placeholder order.
        String[] selectionArgs = { String.valueOf(groupId) };

        // Issue SQL statement.
        db.delete(PriceFinderContract.SavedItems.TABLE_NAME, selection, selectionArgs);
    }

    public static void removeHomeItem(Context cxt, HomeItem homeItem){
        PriceSavingDbHelper dbHelper = new PriceSavingDbHelper(cxt);
        SQLiteDatabase db = dbHelper.getWritableDatabase();

        removeItemsFromGroup(cxt, homeItem.groupId, homeItem.items);

        // Define 'where' part of query.
        String selection = PriceFinderContract.SavedItemGroups._ID + " LIKE ?";

        // Specify arguments in placeholder order.
        String[] selectionArgs = { String.valueOf(homeItem.groupId) };

        // Issue SQL statement.
        db.delete(PriceFinderContract.SavedItemGroups.TABLE_NAME, selection, selectionArgs);
    }
}
