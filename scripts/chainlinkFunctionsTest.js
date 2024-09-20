// Test in :
// https://functions.chain.link/playground
const apiResponse = await Functions.makeHttpRequest({
  url: `https://query1.finance.yahoo.com/v8/finance/chart/CL=F`
})
if (apiResponse.error) {
  console.error(apiResponse.error)
  throw Error('Request failed');
}
const { data } = apiResponse;
console.log('API response data:');
const wtiUsdRaw = (data.chart.result[0].meta.regularMarketPrice);
console.log(wtiUsdRaw);
const wtiUsdTypeIntScaled = Math.round(wtiUsdRaw*100);
console.log(wtiUsdTypeIntScaled);
return Functions.encodeUint256(wtiUsdTypeIntScaled);
// Format the Function script with the following 
// tool to add quotes for each line for Solidity:
// https://onlinetexttools.com/add-quotes-to-lines