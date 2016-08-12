package enterprises.stimes.pricefinder.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import java.util.ArrayList;

import enterprises.stimes.pricefinder.R;
import enterprises.stimes.pricefinder.models.Item;

/**
 * Created by Jacob on 7/17/2016.
 */
public class HomeItemDetailFragmentListAdapter extends ArrayAdapter<Item> {

    private final Context context;
    private final ArrayList<Item> values;

    public HomeItemDetailFragmentListAdapter(Context context, ArrayList<Item> values) {
        super(context, -1, values);
        this.context = context;
        this.values = values;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        LayoutInflater inflater = (LayoutInflater) context
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View rowView = inflater.inflate(R.layout.home_item_detail_frag_list_view_item, parent, false);

        TextView titleView = (TextView) rowView.findViewById(R.id.detailItemTitleText);
        TextView vendorView = (TextView) rowView.findViewById(R.id.detailItemVendorText);
        TextView priceView = (TextView) rowView.findViewById(R.id.detailItemPriceText);

        final int viewPos = position;

        titleView.setText(values.get(position).title);
        vendorView.setText(values.get(position).vendor);
        priceView.setText("$" + Double.toString(values.get(position).price));

        return rowView;
    }

}
