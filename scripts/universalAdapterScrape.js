const puppeteer = require('puppeteer');

    (async () => { // REMOVE IN ADAPTER.JS

        const browser = await puppeteer.launch();
        const page = await browser.newPage();

        await page.goto('https://data.chain.link/ethereum/mainnet/commodities/wti-usd', { waitUntil: 'networkidle2' });
        const featureArticle1 = (await page.$x('/html/body/div[1]/main/section[2]/div[1]/div[1]/div[2]/p'))[0];
        const text1 = await page.evaluate(el => { return el.textContent}, featureArticle1);

        await browser.close();
        const priceFeedWtiUsd = text1.slice(1,text1.length)*100000000;

        console.log(priceFeedWtiUsd); // REMOVE IN ADAPTER.JS

        return BigInt(priceFeedWtiUsd); // BigInt to handle uint errors with Adapter.js

    })(); // REMOVE IN ADAPTER.JS
