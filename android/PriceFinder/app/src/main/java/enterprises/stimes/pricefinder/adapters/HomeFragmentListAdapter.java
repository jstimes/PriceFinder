package enterprises.stimes.pricefinder.adapters;

import android.content.Context;
import android.graphics.Color;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import java.util.ArrayList;

import enterprises.stimes.pricefinder.R;
import enterprises.stimes.pricefinder.models.HomeItem;

/**
 * Created by Jacob on 6/5/2016.
 */
public class HomeFragmentListAdapter extends ArrayAdapter<HomeItem> {

    private final Context context;
    private final ArrayList<HomeItem> values;

    public HomeFragmentListAdapter(Context context, ArrayList<HomeItem> values) {
        super(context, -1, values);
        this.context = context;
        this.values = values;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        LayoutInflater inflater = (LayoutInflater) context
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View rowView = inflater.inflate(R.layout.home_frag_list_view_item, parent, false);

        TextView titleView = (TextView) rowView.findViewById(R.id.homeItemTitleText);
        TextView targetView = (TextView) rowView.findViewById(R.id.homeItemTargetText);
        TextView priceView = (TextView) rowView.findViewById(R.id.homeItemPriceText);

        titleView.setText(values.get(position).title);
        targetView.setText("Target price: " + Double.toString(values.get(position).targetPrice));

        priceView.setText(Double.toString(values.get(position).lowestPrice));
        if(values.get(position).foundTarget){
            //priceView.setTextColor(Color.GREEN);

            rowView.setBackgroundColor(Color.argb(255, 221, 246, 221));
            Log.i("colors", "found target item");
        }
        else {
            //priceView.setTextColor(Color.RED);
        }

        return rowView;
    }
}
