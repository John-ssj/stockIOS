'use strict';

// [START app]
const express = require('express');
const mongoose = require('mongoose');
const path = require('path');
const cors = require('cors');
const UserFinancialProfile = require('./UserFinancialProfile.js');

// MongoDB 连接
mongoose.connect('mongodb+srv://hayleyliu0311:E6gP438V0HudeuVg@stockiosdb.upwfkhg.mongodb.net/StockIOS?retryWrites=true&w=majority&appName=stockIOSDB');

const app = express();

app.use(cors());
app.use(express.json());

const api_key_finnhub = 'cn83jf1r01qplv1ek8f0cn83jf1r01qplv1ek8fg';
const api_key_polygon = 'Rs6kySvg5Yir8e50SPLKAYW9gZXV7Ovr';

function formatDate(date) {
  const months = ["January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"];
  const year = date.getFullYear();
  const month = months[date.getMonth()];
  const day = date.getDate();
  return `${month} ${day}, ${year}`;
}

app.get('/stock/search', async (req, res) => {
  if (!req.query.symbol) { return res.status(400).json({}); }
  const symbolMatches = req.query.symbol.match(/[a-zA-Z]+/g);
  const symbol = symbolMatches ? symbolMatches.join('').toUpperCase() : '';
  if (!symbol) { return res.status(400).json({}); }

  const target_url = `https://finnhub.io/api/v1/search?q=${symbol}&token=${api_key_finnhub}`;
  try {
    const response = await fetch(target_url);
    const data = await response.json();
    if (Object.keys(data).length === 0) {
      res.json({});
    } else {
      const requiredData = data.result.filter(item => /^[A-Za-z]+$/.test(item.symbol)).map(item => ({
        description: item.description,
        symbol: item.symbol
      })).sort((a, b) => a.symbol.localeCompare(b.symbol));
      res.json({ "stocks": requiredData });
    }
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({});
  }
});

async function getStockSummaryCharts(stock, date) {
  let t = new Date(Number(date));
  let data = {};
  try {
    for (let i = 0; i < 4; i++) {
      const time_to = t.toISOString().split('T')[0];
      t.setDate(t.getDate() - 1);
      const time_from = t.toISOString().split('T')[0];
      const target_url = `https://api.polygon.io/v2/aggs/ticker/${stock}/range/60/minute/${time_from}/${time_to}?adjusted=true&sort=asc&apiKey=${api_key_polygon}`;
      const response = await fetch(target_url);
      data = await response.json();
      if (Object.keys(data).length !== 0 && data.resultsCount !== 0) {
        break;
      }
    }
    if (Object.keys(data).length === 0 || data.resultsCount === 0) {
      return {};
    }
    const extracted_data = data.results.map(item => {
      return [item.t, Number(item.vw.toFixed(2))]
    });
    const selected_data = extracted_data.length <= 24 ? extracted_data : extracted_data.slice(-24);
    return {
      "stock": stock,
      "charts": selected_data
    };
  } catch (error) {
    console.error('Error:', error);
    console.log(data);
    return {};
  }
}

// 这些函数应该在调用前确保stock值有效
async function getStockDetailAndSummary(stock) {
  const target_url_1 = `https://finnhub.io/api/v1/stock/profile2?symbol=${stock}&token=${api_key_finnhub}`;
  const target_url_2 = `https://finnhub.io/api/v1/quote?symbol=${stock}&token=${api_key_finnhub}`;
  const target_url_3 = `https://finnhub.io/api/v1/stock/peers?symbol=${stock}&token=${api_key_finnhub}`;
  try {
    const [response_1, response_2, response_3] = await Promise.all([
      fetch(target_url_1),
      fetch(target_url_2),
      fetch(target_url_3)
    ]);
    const [data_1, data_2, data_3] = await Promise.all([
      response_1.json(),
      response_2.json(),
      response_3.json()
    ]);
    if (Object.keys(data_1).length === 0 || Object.keys(data_2).length === 0 || Object.keys(data_3).length === 0) {
      return [{}, ''];
    } else {
      const output_data_3 = data_3.filter(str => /^[A-Za-z]+$/.test(str));

      const outputData = {
        "price": {
          "name": data_1["name"],
          "lastPrice": data_2["c"],
          "change": data_2["d"],
          "changePercent": data_2["dp"]
        },
        "stats": {
          "highPrice": data_2["h"],
          "lowPrice": data_2["l"],
          "openPrice": data_2["o"],
          "prevClose": data_2["pc"]
        },
        "about": {
          "ipo": data_1["ipo"],
          "industry": data_1["finnhubIndustry"],
          "webpage": data_1["weburl"],
          "peers": output_data_3
        }
      };
      return [outputData, data_2["t"] + '000'];
    }
  } catch (error) {
    console.error('Error:', error);
    return [{}, ''];
  }
};

async function getStockNews(stock) {
  let t = new Date();
  const time_to = t.toISOString().split('T')[0];
  t.setDate(t.getDate() - 7);
  const time_from = t.toISOString().split('T')[0];
  const target_url = `https://finnhub.io/api/v1/company-news?symbol=${stock}&from=${time_from}&to=${time_to}&token=${api_key_finnhub}`;
  let selected_data = {};
  try {
    const response = await fetch(target_url);
    const data = await response.json();
    if (Object.keys(data).length === 0) {
      return [];
    } else {
      const filtered_data = data.filter(item =>
        item.headline && item.image && item.source && item.datetime && item.summary && item.url
      );
      selected_data = filtered_data.length <= 20 ? filtered_data : filtered_data.slice(0, 20);
      const extracted_data = selected_data.map(item => {
        // const formattedDate = formatDate(new Date(item.datetime * 1000));
        return {
          "headline": item.headline,
          "imgUrl": item.image,
          "source": item.source,
          "datetime": item.datetime,
          "summary": item.summary,
          "url": item.url,
        }
      });;
      return extracted_data;
    }
  } catch (error) {
    console.error('Error:', error);
    console.log(selected_data);
    return {};
  }
};

async function getStockCharts(stock) {
  let t = new Date();
  const time_to = t.toISOString().split('T')[0];
  t.setFullYear(t.getFullYear() - 2);
  const time_from = t.toISOString().split('T')[0];
  const target_url = `https://api.polygon.io/v2/aggs/ticker/${stock}/range/1/day/${time_from}/${time_to}?adjusted=true&sort=asc&apiKey=${api_key_polygon}`;
  let data = {};
  try {
    const response = await fetch(target_url);
    data = await response.json();
    if (Object.keys(data).length === 0) {
      return {};
    } else {
      const ohlc = data.results.map(item => {
        return [item.t, Number(item.o.toFixed(2)), Number(item.h.toFixed(2)), Number(item.l.toFixed(2)), Number(item.c.toFixed(2))]
      });
      const volume = data.results.map(item => {
        return [item.t, Number(item.v.toFixed(2))]
      });
      return {
        "stock": stock,
        "ohlc": ohlc,
        "volume": volume
      };
    }
  } catch (error) {
    console.error('Error:', error);
    console.log(data);
    return {};
  }
};

async function getStockInsights(stock) {
  const target_url = `https://finnhub.io/api/v1/stock/insider-sentiment?symbol=${stock}&from=2022-01-01&token=${api_key_finnhub}`;
  let filtered_data = {};
  try {
    const response = await fetch(target_url);
    const data = await response.json();
    if (Object.keys(data).length === 0) {
      return {};
    } else {
      filtered_data = data.data.filter(item =>
        item.mspr && item.change
      );
      let totalMspr = 0, positiveMspr = 0, negativeMspr = 0;
      let totalChange = 0, positiveChange = 0, negativeChange = 0;

      filtered_data.forEach(item => {
        totalMspr += item.mspr;
        totalChange += item.change;

        if (item.mspr > 0) positiveMspr += item.mspr;
        if (item.mspr < 0) negativeMspr += item.mspr;

        if (item.change > 0) positiveChange += item.change;
        if (item.change < 0) negativeChange += item.change;
      });

      const extracted_data = {
        "totalMspr": totalMspr,
        "positiveMspr": positiveMspr,
        "negativeMspr": negativeMspr,
        "totalChange": totalChange,
        "positiveChange": positiveChange,
        "negativeChange": negativeChange
      }
      return extracted_data;
    }
  } catch (error) {
    console.error('Error:', error);
    console.log(filtered_data);
    return {};
  }
};

async function getStockInsightsTrendsCharts(stock) {
  const target_url = `https://finnhub.io/api/v1/stock/recommendation?symbol=${stock}&token=${api_key_finnhub}`;
  let data = {};
  try {
    const response = await fetch(target_url);
    data = await response.json();
    if (Object.keys(data).length === 0) {
      return {};
    } else {
      let period_list = [];
      let buy = [];
      let hold = [];
      let sell = [];
      let strongBuy = [];
      let strongSell = [];

      data.forEach(item => {
        const period = item.period.substring(0, 7);
        period_list.push(period);
        buy.push(item.buy);
        hold.push(item.hold);
        sell.push(item.sell);
        strongBuy.push(item.strongBuy);
        strongSell.push(item.strongSell);
      });

      const selected_data = {
        "period": period_list,
        "buy": buy,
        "hold": hold,
        "sell": sell,
        "strongBuy": strongBuy,
        "strongSell": strongSell
      };

      return selected_data;
    }
  } catch (error) {
    console.error('Error:', error);
    console.log(data);
    return {};
  }
}

async function getStockInsightsEPSCharts(stock) {
  const target_url = `https://finnhub.io/api/v1/stock/earnings?symbol=${stock}&token=${api_key_finnhub}`;
  let data = {};
  try {
    const response = await fetch(target_url);
    data = await response.json();
    if (Object.keys(data).length === 0) {
      return {};
    } else {
      let periodAndSurprise_list = [];
      let actual = [];
      let estimate = [];

      data.forEach(item => {
        periodAndSurprise_list.push(item.period + "<br>surprise: " + (item.surprise ? item.surprise : 0));
        actual.push(item.actual ? item.actual : 0);
        estimate.push(item.estimate);
      });
      const selected_data = {
        "periodAndSurprise": periodAndSurprise_list,
        "actual": actual,
        "estimate": estimate
      };

      return selected_data;
    }
  } catch (error) {
    console.error('Error:', error);
    console.log(data);
    return {};
  }
}

app.get('/stock/company', async (req, res) => {
  if (!req.query.symbol) { return res.status(400).json({}); }
  const symbolMatches = req.query.symbol.match(/[a-zA-Z]+/g);
  const symbol = symbolMatches ? symbolMatches.join('').toUpperCase() : '';
  if (!symbol) { return res.status(400).json({}); }
  res.set('Cache-Control', 'no-store');

  try {
    let [return_data, timestamp] = await getStockDetailAndSummary(symbol);
    if (Object.keys(return_data).length === 0) {
      return res.json({});
    }

    const [summaryCharts, stockNews_data, stockCharts_data, stockInsights_data, stockInsightsTrendsCharts_data, stockInsightsEPSCharts_data, portfolio_data] = await Promise.all([
      getStockSummaryCharts(symbol, timestamp),
      getStockNews(symbol),
      getStockCharts(symbol),
      getStockInsights(symbol),
      getStockInsightsTrendsCharts(symbol),
      getStockInsightsEPSCharts(symbol),
      getFinancialInfo(symbol)
    ]);

    return_data["news"] = stockNews_data;
    return_data["insights"] = stockInsights_data;
    return_data["portfolio"] = portfolio_data;
    summaryCharts["change"] = return_data.price.change;
    return_data["hourlyChart"] = JSON.stringify(summaryCharts);
    return_data["SMACharts"] = JSON.stringify(stockCharts_data);
    return_data["recommendCharts"] = JSON.stringify(stockInsightsTrendsCharts_data);
    return_data["EPSCharts"] = JSON.stringify(stockInsightsEPSCharts_data);

    return res.json(return_data);
  } catch (error) {
    console.error('Error:', error);
    return res.status(500).json({});
  }
});

// watchlist和portfolio的操作

async function getStockName(stock) {
  const target_url = `https://finnhub.io/api/v1/stock/profile2?symbol=${stock}&token=${api_key_finnhub}`;
  const response = await fetch(target_url);
  const data = await response.json();
  return data["name"];
}

async function getFinancialPrice(stock) {
  const target_url = `https://finnhub.io/api/v1/quote?symbol=${stock}&token=${api_key_finnhub}`;
  const response = await fetch(target_url);
  const data = await response.json();
  return {
    "currentPrice": data["c"],
    "change": data["d"],
    "changePercent": data["dp"] ? data["dp"] : 0
  };
}

async function getFinancialInfo(stock) {
  try {
    const profile = await UserFinancialProfile.findOne({ id: 0 });
    const watchListExists = profile.watchList.some(item => item.stock === stock);
    const portfolioItem = profile.portfolio.find(item => item.stock === stock);
    if (portfolioItem) {
      const priceData = await getFinancialPrice(portfolioItem.stock);
      const marketValue = Number(priceData.currentPrice) * portfolioItem.quantity;
      const change = marketValue - portfolioItem.totalCost;
      return {
        "favorite": watchListExists,
        "stock": stock,
        "name": portfolioItem.name,
        "quantity": portfolioItem.quantity,
        "avgCost": portfolioItem.totalCost / portfolioItem.quantity,
        "totalCost": portfolioItem.totalCost,
        "change": change,
        "marketValue": marketValue
      };
    } else {
      return {
        "favorite": watchListExists,
        "stock": stock,
        "name": "",
        "quantity": 0,
        "avgCost": 0,
        "totalCost": 0,
        "change": 0,
        "marketValue": 0
      };
    }
  } catch (error) {
    console.error('Error:', error);
    return {}
  }
}

async function getPortfolio() {
  try {
    const profile = await UserFinancialProfile.findOne({ id: 0 });
    if (profile) {
      const wallet = profile.wallet;
      const portfolioData = await Promise.all(profile.portfolio.map(async (item) => {
        const priceData = await getFinancialPrice(item.stock);
        const marketValue = Number(priceData.currentPrice) * item.quantity;
        const change = marketValue - item.totalCost;
        return {
          "stock": item.stock,
          "quantity": item.quantity,
          "marketValue": marketValue,
          "change": change,
          "changePercent": change / item.totalCost * 100,
          "index": item.index
        };
      }));
      return { "wallet": wallet, "portfolio": portfolioData };
    } else {
      return {};
    }
  } catch (error) {
    console.error('Error:', error);
    return {};
  }
}

async function getWatchList() {
  try {
    const profile = await UserFinancialProfile.findOne({ id: 0 });
    if (profile) {
      const watchListData = await Promise.all(profile.watchList.map(async (item) => {
        const priceData = await getFinancialPrice(item.stock);
        return {
          "stock": item.stock,
          "name": item.name,
          "currentPrice": priceData.currentPrice,
          "change": priceData.change,
          "changePercent": priceData.changePercent,
          "index": item.index
        };
      }));
      return watchListData;
    } else {
      return {};
    }
  } catch (error) {
    console.error('Error:', error);
    return {};
  }
}

app.get('/financial/init', async (req, res) => {
  res.set('Cache-Control', 'no-store');
  try {
    await UserFinancialProfile.deleteOne({ id: 0 });

    const newUserFinancialProfile = new UserFinancialProfile({
      id: 0,
      wallet: 25000,
      watchListIndex: 0,
      portfolioIndex: 0,
      watchList: [],
      portfolio: [],
    });

    await newUserFinancialProfile.save();

    res.send({ "success": true });
  } catch (error) {
    console.error('Error initializing user financial profile:', error);
    res.status(500).send({});
  }
});

app.get('/financial/getAll', async (req, res) => {
  res.set('Cache-Control', 'no-store');
  const data = await getPortfolio();
  const watchList_data = await getWatchList();
  data["watchList"] = watchList_data;
  res.json(data);
});

app.get('/financial/getInfo', async (req, res) => {
  res.set('Cache-Control', 'no-store');
  if (!req.query.symbol) { return res.json({}); }
  const symbolMatches = req.query.symbol.match(/[a-zA-Z]+/g);
  const symbol = symbolMatches ? symbolMatches.join('').toUpperCase() : '';
  if (!symbol) { res.json({}); }

  try {
    const result = await getFinancialInfo(symbol);
    res.json(result);
    return;
  } catch (error) {
    console.error('Error:', error);
    res.json({});
    return;
  }
});

app.get('/financial/getPrice', async (req, res) => {
  res.set('Cache-Control', 'no-store');
  if (!req.query.symbol) { return res.json({}); }
  const symbolMatches = req.query.symbol.match(/[a-zA-Z]+/g);
  const symbol = symbolMatches ? symbolMatches.join('').toUpperCase() : '';
  if (!symbol) { res.json({}); }

  try {
    const profile = await UserFinancialProfile.findOne({ id: 0 });
    const portfolioItem = profile.portfolio.find(item => item.stock === symbol);
    const quantity = portfolioItem ? portfolioItem.quantity : 0;
    const price = await getFinancialPrice(symbol);
    res.json({ "wallet": profile.wallet, "currentPrice": price.currentPrice, "quantity": quantity });
  } catch (error) {
    res.json({});
  }
});

app.get('/financial/addWatchList', async (req, res) => {
  res.set('Cache-Control', 'no-store');
  if (!req.query.symbol) { return res.status(400).json({}); }
  const symbolMatches = req.query.symbol.match(/[a-zA-Z]+/g);
  const symbol = symbolMatches ? symbolMatches.join('').toUpperCase() : '';
  if (!symbol) { return res.status(400).json({}); }

  try {
    const profile = await UserFinancialProfile.findOne({ id: 0 });
    const watchListExists = profile.watchList.some(item => item.stock === symbol);
    if (watchListExists) { return res.json({}); }
    const stock_name = await getStockName(symbol);
    profile.watchListIndex += 1;
    profile.watchList.push({
      stock: symbol,
      name: stock_name,
      index: profile.watchListIndex
    });
    await profile.save();
    res.json({ "success": true });
    return;
  } catch (error) {
    console.error('Error:', error);
    res.json({});
  }
});

app.get('/financial/removeWatchList', async (req, res) => {
  res.set('Cache-Control', 'no-store');
  if (!req.query.symbol) { return res.status(400).json({}); }
  const symbolMatches = req.query.symbol.match(/[a-zA-Z]+/g);
  const symbol = symbolMatches ? symbolMatches.join('').toUpperCase() : '';
  if (!symbol) { return res.status(400).json({}); }

  try {
    const profile = await UserFinancialProfile.findOne({ id: 0 });
    const watchListExists = profile.watchList.some(item => item.stock === symbol);
    if (!watchListExists) { return res.json({}); }
    const stock_name = await getStockName(symbol);
    profile.watchListIndex -= 1;
    const watchListItemIndex = profile.watchList.find(item => item.stock === symbol).index;
    profile.watchList = profile.watchList.filter(item => {
      if (item.index > watchListItemIndex) {
        item.index -= 1;
      }
      return item.stock !== symbol
    });
    await profile.save();
    res.json({ "success": true });
    return;
  } catch (error) {
    console.error('Error:', error);
    res.json({});
  }
});

app.post('/financial/sortWatchList', async (req, res) => {
  res.set('Cache-Control', 'no-store');

  try {
    const profile = await UserFinancialProfile.findOne({ id: 0 });
    if (profile) {
      const watchListFromRequest = req.body.sort;
      const hasDuplicates = new Set(watchListFromRequest).size !== watchListFromRequest.length;
      if (!hasDuplicates) {
        const watchListDB = profile.watchList.map(item => item.stock);
        const isEqual = watchListFromRequest.length === watchListDB.length &&
          watchListFromRequest.every(item => watchListDB.includes(item));
        console.log("watchListFromRequest: ", watchListFromRequest);
        console.log("watchListDB: ", watchListDB);
        console.log("isEqual: ", isEqual);
        if (isEqual) {
          watchListFromRequest.forEach((stock, index) => {
            const itemIndex = profile.watchList.findIndex(item => item.stock === stock);
            profile.watchList[itemIndex].index = index + 1;
            console.log(profile.watchList[itemIndex].stock, profile.watchList[itemIndex].index);
          });
          await profile.save();
          res.json({ "success": true });
          return;
        }
      }
    }
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({});
  }
  res.send({});
});

app.get('/financial/buy', async (req, res) => {
  res.set('Cache-Control', 'no-store');
  if (!req.query.symbol || !req.query.quantity) { return res.status(400).json({}); }
  const symbolMatches = req.query.symbol.match(/[a-zA-Z]+/g);
  const symbol = symbolMatches ? symbolMatches.join('').toUpperCase() : '';
  if (!symbol) { return res.status(400).json({}); }
  const quantity = Number(req.query.quantity);
  if (!Number.isInteger(quantity) || quantity <= 0) { return res.status(400).json({}); }

  const profile = await UserFinancialProfile.findOne({ id: 0 });
  if (profile) {
    const wallet = profile.wallet;
    const priceData = await getFinancialPrice(symbol);
    const cost = priceData.currentPrice * quantity;
    if (wallet >= cost) {
      if (profile.wallet >= cost) {
        const portfolioItem = profile.portfolio.find(item => item.stock === symbol);
        if (portfolioItem) {
          portfolioItem.quantity += quantity;
          portfolioItem.totalCost += cost;
        } else {
          const stockName = await getStockName(symbol);
          profile.portfolioIndex += 1;
          profile.portfolio.push({
            stock: symbol,
            name: stockName,
            quantity: quantity,
            totalCost: cost,
            index: profile.portfolioIndex
          });
        }
        profile.wallet -= cost;
        await profile.save();
        res.json({"success": true});
        return;
      }
    } else {
      res.json({});
      return;
    }
  }
  res.status(500).send({});
});

app.get('/financial/sell', async (req, res) => {
  res.set('Cache-Control', 'no-store');
  if (!req.query.symbol || !req.query.quantity) { return res.status(400).json({}); }
  const symbolMatches = req.query.symbol.match(/[a-zA-Z]+/g);
  const symbol = symbolMatches ? symbolMatches.join('').toUpperCase() : '';
  if (!symbol) { return res.status(400).json({}); }
  const quantity = Number(req.query.quantity);
  if (!Number.isInteger(quantity) || quantity <= 0) { return res.status(400).json({}); }

  const profile = await UserFinancialProfile.findOne({ id: 0 });
  if (profile) {
    const portfolioItem = profile.portfolio.find(item => item.stock === symbol);
    if (!portfolioItem || portfolioItem.quantity < quantity) {
      res.json({});
      return;
    }
    const priceData = await getFinancialPrice(symbol);
    const cost = priceData.currentPrice * quantity;
    portfolioItem.quantity -= quantity;
    if (portfolioItem.quantity === 0) {
      profile.portfolioIndex -= 1;
      const portfolioItemIndex = profile.portfolio.find(item => item.stock === symbol).index;
      profile.portfolio = profile.portfolio.filter(item => {
        if (item.index > portfolioItemIndex) {
          item.index -= 1;
        }
        return item.stock !== symbol
      });
    } else {
      portfolioItem.totalCost -= cost;
    }
    profile.wallet += cost;
    await profile.save();

    res.json({"success": true});
    return;
  }
  res.json({});
  return;
});


app.post('/financial/sortPortfolio', async (req, res) => {
  res.set('Cache-Control', 'no-store');

  try {
    const profile = await UserFinancialProfile.findOne({ id: 0 });
    if (profile) {
      const portfolioFromRequest = req.body.sort;
      const hasDuplicates = new Set(portfolioFromRequest).size !== portfolioFromRequest.length;
      if (!hasDuplicates) {
        const portfolioDB = profile.portfolio.map(item => item.stock);
        const isEqual = portfolioFromRequest.length === portfolioDB.length &&
          portfolioFromRequest.every(item => portfolioDB.includes(item));
        console.log("portfolioFromRequest: ", portfolioFromRequest);
        console.log("portfolioDB: ", portfolioDB);
        console.log("isEqual: ", isEqual);
        if (isEqual) {
          portfolioFromRequest.forEach((stock, index) => {
            const itemIndex = profile.portfolio.findIndex(item => item.stock === stock);
            profile.portfolio[itemIndex].index = index + 1;
            console.log(profile.portfolio[itemIndex].stock, profile.portfolio[itemIndex].index);
          });
          await profile.save();
          res.json({ "success": true });
          return;
        }
      }
    }
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({});
  }
  res.send({});
});

// Listen to the App Engine-specified port, or 8080 otherwise
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}...`);
});
// [END app]

module.exports = app;