const axios = require("axios");

getJsonValues()

async function getJsonValues() {

    // let baseUrl = "http://127.0.0.1:8080/"
    // Yahoo Finance API for crude oil price data.
    // "CL=F"
    // is the symbol for WTI crude oil futures. 
    // Yahoo Finance uses this symbol to identify the commodity you're querying.
    let baseUrl = "https://query1.finance.yahoo.com/v8/finance/chart/CL=F"
    let responseRawJSON = await axios.get(baseUrl);
    let responseDataJSON = responseRawJSON.data;
    console.log(responseRawJSON)
    console.log(responseDataJSON)
    console.log(responseDataJSON.chart.result[0].meta.shortName)
    console.log(responseDataJSON.chart.result[0].meta.instrumentType)
    console.log(responseDataJSON.chart.result[0].meta.regularMarketPrice)
    console.log(responseDataJSON.chart.result[0].meta.regularMarketPrice*100)

}