package enterprises.stimes.pricefinder;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ListView;
import android.widget.SearchView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.HashSet;

import enterprises.stimes.pricefinder.adapters.SearchFragmentListAdapter;
import enterprises.stimes.pricefinder.models.Item;
import enterprises.stimes.pricefinding.scraping.SearchRunner;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link SearchFragment.SearchFragmentAddListener} interface
 * to handle interaction events.
 * Use the {@link SearchFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class SearchFragment extends Fragment implements SearchFragmentListAdapter.SearchCheckBoxListener,
        SearchView.OnQueryTextListener, SearchRunner.SearchRunnerResultHandler {

    private Button addBtn;
    private ListView searchList;
    private SearchView searchView;
    private MainActivity mainActivity;

    SearchFragmentListAdapter adapter;
    private ArrayList<Item> allItems = new ArrayList<>();
    //TODO change to indices
    private HashSet<Integer> checkedItems = new HashSet<Integer>();

    String searchText;

    private SearchFragmentAddListener mListener;

    public SearchFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @return A new instance of fragment SearchFragment.
     */
    public static SearchFragment newInstance() {
        SearchFragment fragment = new SearchFragment();
//        Bundle args = new Bundle();
//        args.putString(ARG_PARAM1, param1);
//        args.putString(ARG_PARAM2, param2);
//        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        /*if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }*/
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        final View fragView = inflater.inflate(R.layout.fragment_search, container, false);

        addBtn = (Button) fragView.findViewById(R.id.searchFragmentAddButton);
        addBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onAddBtnClicked();
            }
        });

        searchList = (ListView) fragView.findViewById(R.id.searchFragmentListView);
        adapter = new SearchFragmentListAdapter(this.getContext(), allItems, this);
        searchList.setAdapter(adapter);
        searchList.setOnItemClickListener(new AdapterView.OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view,
                                    int position, long id) {
                Toast.makeText(SearchFragment.this.getContext(),
                        "Click ListItem Number " + position, Toast.LENGTH_LONG)
                        .show();
            }

        });
        adapter.notifyDataSetChanged();

        searchView = (SearchView) fragView.findViewById(R.id.searchFragmentSearchView);
        searchView.setOnQueryTextListener(this);

        searchView.setIconifiedByDefault(false);

        mainActivity.setActionBarText("Search");
        mainActivity.showBackButton(false);
        mainActivity.showEditButton(false);

        return fragView;
    }

    public void onAddBtnClicked() {
        if (mListener != null) {
            ArrayList<Item> items = new ArrayList<>();
            for (Integer key : checkedItems) {
                items.add(allItems.get(key));
            }
            mListener.onSearchFragmentAddBtnClicked(searchText, items);
        }
        clearSearch();
        Toast.makeText(getContext(), "Items saved!", Toast.LENGTH_SHORT).show();
    }

    private void clearSearch(){
        checkedItems.clear();
        allItems.clear();
        adapter.notifyDataSetChanged();
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof SearchFragmentAddListener) {
            mListener = (SearchFragmentAddListener) context;
            mainActivity = (MainActivity)context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    public void onSearchCheckBoxClicked(int index){
        if(checkedItems.contains(index)){
            checkedItems.remove(index);
        }
        else {
            checkedItems.add(index);
        }

        if(checkedItems.size() > 0){
            addBtn.setEnabled(true);
        }
        else {
            addBtn.setEnabled(false);
        }
        Log.i("checkBtn", "yup");
    }

    @Override
    public boolean onQueryTextChange(String newText){
        return false;
    }

    @Override
    public boolean onQueryTextSubmit(String query){
        Toast.makeText(getContext(), "User searched for: " + query, Toast.LENGTH_SHORT).show();

        //Dismiss keyboard:

        InputMethodManager imm = (InputMethodManager) getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
        if(imm.isAcceptingText()) {
            imm.hideSoftInputFromWindow(getActivity().getCurrentFocus().getWindowToken(), 0);
        }

        this.searchText = query;
        clearSearch();
        SearchRunner.Search(query, this);

        //TODO Show loading...

        return true;
    }

    public void searchFinished(ArrayList<Item> searchResults){
        Log.i("network", "Search finished");
        allItems.clear();
        allItems.addAll(searchResults);
        adapter.notifyDataSetChanged();
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
    public interface SearchFragmentAddListener {

        void onSearchFragmentAddBtnClicked(String search, ArrayList<Item> items);
    }
}
