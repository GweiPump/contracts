// Test in :
// https://functions.chain.link/playground
const apiResponse = await Functions.makeHttpRequest({
  url: `https://query1.finance.yahoo.com/v8/finance/chart/CL=F`
})

if (apiResponse.error) {
  console.error(apiResponse.error)
  throw Error("Request failed")
}

const { data } = apiResponse;
console.log('API response data:');
const wtiUsd = 100*(data.chart.result[0].meta.regularMarketPrice)
console.log(wtiUsd);
return Functions.encodeUint256(wtiUsd)
