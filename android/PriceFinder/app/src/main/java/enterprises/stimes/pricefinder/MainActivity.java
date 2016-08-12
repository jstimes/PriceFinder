package enterprises.stimes.pricefinder;

import android.support.v7.app.ActionBar;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.FragmentTabHost;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TabHost;
import android.widget.TextView;

import java.util.ArrayList;

import enterprises.stimes.pricefinder.models.HomeItem;
import enterprises.stimes.pricefinder.models.Item;
import enterprises.stimes.pricesaving.PriceSavingDbHelper;

public class MainActivity extends AppCompatActivity implements SearchFragment.SearchFragmentAddListener,
        HomeFragment.OnHomeFragmentItemViewListener {

    private FragmentTabHost mTabHost;

    private TextView titleTextView;
    private ActionBar actionBar;
    private Button editButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        //getSupportActionBar().setTitle("PriceFinder");

        actionBar = getSupportActionBar();

        //abar.setBackgroundDrawable(getDrawable(R.drawable.action_bar));//line under the action bar
        View viewActionBar = getLayoutInflater().inflate(R.layout.action_bar, null);
        ActionBar.LayoutParams params = new ActionBar.LayoutParams(//Center the textview in the ActionBar !
                ActionBar.LayoutParams.WRAP_CONTENT,
                ActionBar.LayoutParams.MATCH_PARENT,
                Gravity.CENTER);
        titleTextView = (TextView) viewActionBar.findViewById(R.id.my_action_bar_title);
        //titleTextView.setText("Test");

        editButton = (Button) viewActionBar.findViewById(R.id.action_bar_edit_button);

        actionBar.setCustomView(viewActionBar, params);
        actionBar.setDisplayShowCustomEnabled(true);
        actionBar.setDisplayShowTitleEnabled(false);

        actionBar.setIcon(R.color.colorPrimaryDark);

        mTabHost = (FragmentTabHost)findViewById(android.R.id.tabhost);
        mTabHost.setup(this, getSupportFragmentManager(), R.id.realtabcontent);

        //Home tab:
        TabHost.TabSpec homeTab = mTabHost.newTabSpec("Home");
        View homeLayout = LayoutInflater.from(this).inflate(R.layout.tab_content, mTabHost.getTabWidget(), false);
        ((TextView)homeLayout.findViewById(R.id.tab_text)).setText("Home");
        ((ImageView)homeLayout.findViewById(R.id.tab_icon))
                .setImageDrawable(ContextCompat.getDrawable(this, R.drawable.home_tab_selector));
        homeTab.setIndicator(homeLayout);
        mTabHost.addTab(homeTab, HomeFragment.class, null);

        // Recommendations/what's hot tab:
        TabHost.TabSpec recomTab = mTabHost.newTabSpec("Recommendations");
        View recomLayout = LayoutInflater.from(this).inflate(R.layout.tab_content, mTabHost.getTabWidget(), false);
        ((TextView)recomLayout.findViewById(R.id.tab_text)).setText("Hot");
        ((ImageView)recomLayout.findViewById(R.id.tab_icon))
                .setImageDrawable(ContextCompat.getDrawable(this, R.drawable.recommendations_tab_selector));
        recomTab.setIndicator(recomLayout);
        mTabHost.addTab(recomTab, RecommendationsFragment.class, null);

        //Search tab:
        TabHost.TabSpec searchTab = mTabHost.newTabSpec("Search");
        View searchLayout = LayoutInflater.from(this).inflate(R.layout.tab_content, mTabHost.getTabWidget(), false);
        ((TextView)searchLayout.findViewById(R.id.tab_text)).setText("Search");
        ((ImageView)searchLayout.findViewById(R.id.tab_icon))
                .setImageDrawable(ContextCompat.getDrawable(this, R.drawable.search_tab_selector));
        searchTab.setIndicator(searchLayout);
        mTabHost.addTab(searchTab, SearchFragment.class, null);

        //Profile tab:
        TabHost.TabSpec profileTab = mTabHost.newTabSpec("Profile");
        View profileLayout = LayoutInflater.from(this).inflate(R.layout.tab_content, mTabHost.getTabWidget(), false);
        ((TextView)profileLayout.findViewById(R.id.tab_text)).setText("Profile");
        ((ImageView)profileLayout.findViewById(R.id.tab_icon))
                .setImageDrawable(ContextCompat.getDrawable(this, R.drawable.profile_tab_selector));
        profileTab.setIndicator(profileLayout);
        mTabHost.addTab(profileTab, ProfileFragment.class, null);

        for(int i=0; i<mTabHost.getTabWidget().getTabCount(); i++){
            mTabHost.getTabWidget().getChildAt(i).setBackgroundColor(Color.parseColor("#B3E5FC"));
        }

    }

    public void setActionBarText(String title){
        titleTextView.setText(title);
    }

    public void showBackButton(boolean show){
        actionBar.setHomeButtonEnabled(show);
        actionBar.setDisplayHomeAsUpEnabled(show);
    }

    public void showEditButton(boolean show){
        if(show) {
            editButton.setVisibility(View.VISIBLE);
        }
        else {
            editButton.setVisibility(View.INVISIBLE);
        }
    }

    public void setEditOnClickListener(View.OnClickListener listener){
        editButton.setOnClickListener(listener);
    }

    public void onSearchFragmentAddBtnClicked(String search, ArrayList<Item> items) {
        //TODO go to set target price & confirm screen
        Log.i("add btn", "Go to target price & confirm screen");

        double target = 35.0;

        PriceSavingDbHelper.insert(this, search, target, items);

        Log.i("DB", "Inserted items");
    }

    public void onHomeItemSelected(HomeItem item){
        Log.i("home item", "Go to HomeItem screen");

        //Currently having some issues with this fragment
//        HomeItemDetailFragment detailFragment = HomeItemDetailFragment.newInstance(item);
//        getSupportFragmentManager()
//                .beginTransaction()
//                .replace(R.id.realtabcontent, detailFragment)
//                .addToBackStack(null)
//                .commit();
//        return;
    }

    @Override
    public boolean onSupportNavigateUp() {
        //This method is called when the up button is pressed. Just pop back stack.
        getSupportFragmentManager().popBackStack();
        return true;
    }

}
