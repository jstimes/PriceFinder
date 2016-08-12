package enterprises.stimes.pricefinder.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.TextView;

import java.util.ArrayList;

import enterprises.stimes.pricefinder.R;
import enterprises.stimes.pricefinder.models.Item;

/**
 * Created by Jacob on 6/3/2016.
 */
public class SearchFragmentListAdapter extends ArrayAdapter<Item> {

    public interface SearchCheckBoxListener {
        void onSearchCheckBoxClicked(int index);
    }

    private final Context context;
    private final ArrayList<Item> values;
    SearchCheckBoxListener mListener;

    public SearchFragmentListAdapter(Context context, ArrayList<Item> values, SearchCheckBoxListener listener) {
        super(context, -1, values);
        this.context = context;
        this.values = values;
        this.mListener = listener;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        LayoutInflater inflater = (LayoutInflater) context
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View rowView = inflater.inflate(R.layout.search_frag_list_view_item, parent, false);

        TextView titleView = (TextView) rowView.findViewById(R.id.searchItemTitleText);
        TextView vendorView = (TextView) rowView.findViewById(R.id.searchItemVendorText);
        TextView priceView = (TextView) rowView.findViewById(R.id.searchItemPriceText);

        final int viewPos = position;
        CheckBox checkbox = (CheckBox) rowView.findViewById(R.id.searchItemCheckBox);
        checkbox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                SearchFragmentListAdapter.this.mListener.onSearchCheckBoxClicked(viewPos);
                values.get(position).setSelected(isChecked);
            }
        });

        titleView.setText(values.get(position).title);
        vendorView.setText(values.get(position).vendor);
        priceView.setText("$" + Double.toString(values.get(position).price));
        checkbox.setChecked(values.get(position).selected);

        return rowView;
    }
}

