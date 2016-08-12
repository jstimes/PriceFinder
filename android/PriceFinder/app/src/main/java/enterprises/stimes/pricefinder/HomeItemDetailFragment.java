package enterprises.stimes.pricefinder;


import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;
import android.widget.TextView;

import enterprises.stimes.pricefinder.adapters.HomeItemDetailFragmentListAdapter;
import enterprises.stimes.pricefinder.models.HomeItem;
import enterprises.stimes.pricesaving.PriceSavingDbHelper;


/**
 * A simple {@link Fragment} subclass.
 * Use the {@link HomeItemDetailFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class HomeItemDetailFragment extends Fragment {

    public HomeItem homeItem;

    private MainActivity mainActivity;

    private ListView itemsListView;
    private HomeItemDetailFragmentListAdapter adapter;

    public HomeItemDetailFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     * @return A new instance of fragment HomeItemDetailFragment.
     */
    public static HomeItemDetailFragment newInstance(HomeItem homeItem) {
        HomeItemDetailFragment fragment = new HomeItemDetailFragment();
        fragment.homeItem = homeItem;
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onAttach(Context context){
        super.onAttach(context);

        mainActivity = (MainActivity) context;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_home_item_detail, container, false);

        TextView searchTextView = (TextView) view.findViewById(R.id.homeItemDetailSearchText);
        searchTextView.setText(homeItem.title);

        TextView targetTextView = (TextView) view.findViewById(R.id.homeItemDetailSearchText);
        targetTextView.setText("Target price: " + homeItem.targetPrice);

        TextView lowestTextView = (TextView) view.findViewById(R.id.homeItemDetailLowestPrice);
        lowestTextView.setText("Lowest price found: " + homeItem.lowestPrice);

        TextView dateTextView = (TextView) view.findViewById(R.id.homeItemDetailDateAdded);
        //dateTextView.setText("Lowest price found: " + homeItem.);

        itemsListView = (ListView) view.findViewById(R.id.homeItemDetailItemsList);
        adapter = new HomeItemDetailFragmentListAdapter(getContext(), this.homeItem.items);
        itemsListView.setAdapter(adapter);
        itemsListView.deferNotifyDataSetChanged();

        mainActivity.showBackButton(true);
        mainActivity.showEditButton(true);

        mainActivity.setEditOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                PriceSavingDbHelper.updateTargetPriceForGroupId(getContext(), homeItem.groupId, 100.0);
            }
        });

        return view;
    }

    @Override
    public void onDetach(){
        super.onDetach();
        Log.i("Frags", "Detached");
    }

}
