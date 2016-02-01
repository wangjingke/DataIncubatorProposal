## Data Incubator Fellowship Challenge Proposal

This proposal is for current or potential restaurant owners in Los Angeles, and other major cities in the US. Just like Yelp helping finding restaurants, my project can help determine where the best place is to open a restaurant in the city, and what the fittest flavor is for the picked spot.

Los Angeles is a vibrant and vivid city, and her palate changes all the time. In order to be a successful restaurant owner, it is important to understand the trends and traditions embedded in local people’s tastes, which is the question I would like to answer. I have scrapped demographic information about Los Angeles from public hosts, downloaded the complete list of active restaurants from the city website, and requested LA geographic data through Google Map API. Combining these data, I am able to run a preliminary analysis and build up a profile for Los Angeles’ favorite flavors.

The first plot compares the distribution of all active restaurants in the Los Angeles area, and the newly established ones in 2015. The total number of active restaurants in LA stays near 7000 over the years, but more than 500 new restaurants opened their business just in 2015, which is another sidenote indicating the fierceness of the competition in the restaurant industry. New restaurants, on the contrary to spreading over LA, concentrated in the downtown area, along with the Korean and Chinese districts. The second plots summarized the Moran statistical results on the total number, as well as percentage increment of restaurants by LA zip codes. We can see a clear pattern of scattering by regions, which tells us that some places are more favorable to open a restaurants than the others. Results from the autoregressive model confirmed that changes in population size and ethnic composition are the major driven forces behind all these shifts. In other words, the newly established restaurants are here to satisfy the demand of increasing population and feed the hunger for specific ethnic flavors.

It becomes really interesting when detailed restaurant data are pulled from Yelp API. We can see that these new restaurants are more likely to be serving Mexican or Asian (Chinese or Korean) cuisines or fusion of cross-cultural flavors. This trend happens to synchronize beautifully with the thriving flux of Hispanic and Asian immigrants coming to Los Angeles in the recent years.

The next step is to bring in menu and comment data from website such Yelp and Allmenus. Natural language processing on these data can tell us valuable information. For example, we can determine the most welcomed dishes currently in a region; the price of the same dish from competitors; the favorable cuisine styles; the size of the potential customer cohort. Especially, after analyzing the comments along the time line, we may find out and eventually predict what people want from the restaurants, and that is when we get a feel of the pulse of the restaurant industry.


* Los Angeles demographic information
  * http://www.laalmanac.com/population/po24la_zip.htm
  * http://proximityone.com/zipdp2.htm


* Los Angeles Active Restaurant List
  * https://data.lacity.org/A-Prosperous-City/Active-restaurant-heat-map/pwji-zbmi
