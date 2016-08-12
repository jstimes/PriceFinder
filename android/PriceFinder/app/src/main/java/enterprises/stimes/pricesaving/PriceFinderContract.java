package enterprises.stimes.pricesaving;

import android.provider.BaseColumns;

/**
 * Defines SQLlite database schema
 * Created by Jacob on 7/16/2016.
 */
public final class PriceFinderContract {

    public PriceFinderContract() {}

    public static abstract class SavedItemGroups implements BaseColumns {
        public static final String TABLE_NAME = "savedItemGruops";

        public static final String COLUMN_NAME_TARGET_PRICE = "targetprice";

        public static final String COLUMN_NAME_SEARCH_TEXT = "searchtext";

        public static final String COLUMN_NAME_ = "savedId";
    }

    public static abstract class SavedItems implements BaseColumns {
        public static final String TABLE_NAME = "savedItems";

        public static final String COLUMN_NAME_GROUP_ID = "savedItemGroupId";

        public static final String COLUMN_NAME_TITLE = "title";

        public static final String COLUMN_NAME_PRICE = "price";

        public static final String COLUMN_NAME_VENDOR = "vendor";

        public static final String COLUMN_NAME_DESCRIPTION = "description";
    }
}
