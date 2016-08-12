package enterprises.stimes.pricefinder;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;

import java.util.ArrayList;

import enterprises.stimes.pricefinder.adapters.HomeFragmentListAdapter;
import enterprises.stimes.pricefinder.models.HomeItem;
import enterprises.stimes.pricesaving.PriceSavingDbHelper;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link HomeFragment.OnHomeFragmentItemViewListener} interface
 * to handle interaction events.
 * Use the {@link HomeFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class HomeFragment extends Fragment {

    private OnHomeFragmentItemViewListener mListener;
    private ListView list;
    private HomeFragmentListAdapter adapter;
    private MainActivity mainActivity;

    ArrayList<HomeItem> items = new ArrayList<>();//HomeItem.getData();

    public HomeFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
    *
     * @return A new instance of fragment HomeFragment.
     */
    public static HomeFragment newInstance() {
        HomeFragment fragment = new HomeFragment();
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        // Inflate the layout for this fragment
        View layout = inflater.inflate(R.layout.fragment_home, container, false);

        this.list = (ListView) layout.findViewById(R.id.home_page_list);
        adapter = new HomeFragmentListAdapter(getContext(), this.items);
        this.list.setAdapter(adapter);
        adapter.notifyDataSetChanged();
        this.list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                HomeFragment.this.mListener.onHomeItemSelected(items.get(position));
            }
        });

        final ArrayList<HomeItem> homeItems = PriceSavingDbHelper.getHomeItems(getContext());
        this.items.clear();
        this.items.addAll(homeItems);
        adapter.notifyDataSetChanged();

        Log.i("DB", "Read " + items.size() + " items");

        mainActivity.setActionBarText("Find List");
        mainActivity.showBackButton(false);
        mainActivity.showEditButton(true);
        mainActivity.setEditOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                PriceSavingDbHelper.removeHomeItem(getContext(), homeItems.get(4));
                Log.i("DB", "Deleted");
            }
        });

        return layout;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnHomeFragmentItemViewListener) {
            mListener = (OnHomeFragmentItemViewListener) context;
            mainActivity = (MainActivity) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement frag Listener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
       // mListener = null;
    }

    /**
     * This interface must be implemented by activities that contain this
     * fragment to allow an interaction in this fragment to be communicated
     * to the activity and potentially other fragments contained in that
     * activity.
     * <p/>
     * See the Android Training lesson <a href=
     * "http://developer.android.com/training/basics/fragments/communicating.html"
     * >Communicating with Other Fragments</a> for more information.
     */
    public interface OnHomeFragmentItemViewListener {
        void onHomeItemSelected(HomeItem item);
    }
}
