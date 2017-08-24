using System;
using System.Collections;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using System.Net.Sockets;
using System.Net;
using System.IO;
using System.Xml.Serialization;
using System.Xml.Linq;
using System.Configuration;
using System.Xml;
using System.Xml.XPath;
using OME.Storage;

namespace Clearing_House
{
    class ClearingHouse
    {
        static void Main(string[] args)
        {
            // need to set up listener threads and sender threads
            // listen to trade engine -> check margin -> forward trade to exchange
            // listen to exchange for order execution and margin checks. Daily? should we do sooner?

            
            //New Order comes from trade engine and goes through checkTraderMargin which checks and submits to exchange
            // I think we may need to add a flag if order is outstanding or executed

            checkTraderMargin(new FuturesOrder("BAC", "Limit", "B", 154, 5, 2, 2, "Delete"));
            checkTraderMargin(new FuturesOrder("BAC", "Limit", "B", 154, 5, 2, 2, "New")); // all orders from trade engine should be handled through checkTraderMargin

            //Delete order gets passes straight through to the exchange, trader log should be updated after the order is sucessfully deleted


            //Update order??? I would say break it into two parts check margin for new order and remove previous order after it has been removed from the order book???


            //executed order confirmations, we should update the price in the trader log with the actual price
            checkTraderMargin(new FuturesOrder("BAC", "Limit", "B", 154, 5, 2, 2, "New", "Denied"));


            tradeExecuted(new ExecutedOrders(newOrder, newOrder.Quantity, (newOrder.LimitPrice - 5))); // trade executed should handle all confirmations from exchange

        }
        static void checkTraderMargin(Order newOrder) 
        {
            double accountBalance;
            double requiredMargin;
            double newInitialOrderMargin;
            double newOrderMaintMargin;
            int curQuantity;
            double price;

            if (newOrder.OrderAction == "Delete") // will be handled when exchange sends confirmation
            {
                //forward order to exchange
                return;
            }

            XmlDocument doc = new XmlDocument();
            //String traderLog = Environment.CurrentDirectory.ToString() + "\\clearingLog.xml"; can do this but would have to put the xml in bin folder
            String traderLog = ConfigurationManager.AppSettings["ClearingTraderLogPath"].ToString();
            doc.Load(@traderLog);
            String ID = newOrder.CustomerID.ToString();
            
            XmlNode traderNode =  doc.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='" + ID + "']");
            


            try // may be a better way to do this
            {
                accountBalance = Convert.ToDouble(traderNode.SelectSingleNode("Balance").InnerText);
                requiredMargin = Convert.ToDouble(traderNode.SelectSingleNode("RequiredMargin").InnerText);
                newInitialOrderMargin = newOrder.LimitPrice * newOrder.Quantity * Convert.ToDouble(ConfigurationManager.AppSettings["initialMargin"]);
                newOrderMaintMargin = newOrder.LimitPrice * newOrder.Quantity * Convert.ToDouble(ConfigurationManager.AppSettings["maintMargin"]);
                if (accountBalance - requiredMargin > newInitialOrderMargin)
                {//will need to update for stop orders and market orders
                    //send order to exchange

                    //need to think of a better way to do this update required margin
                    curQuantity = Convert.ToInt32(traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Quantity").InnerText);
                    price = Convert.ToDouble(traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Quantity").InnerText);
                    price = (price * curQuantity + newOrder.Quantity * newOrder.LimitPrice)/(curQuantity + newOrder.Quantity);
                    traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Price").InnerText = price.ToString("#.##");
                    traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Quantity").InnerText = (newOrder.Quantity + curQuantity).ToString();
                    traderNode.SelectSingleNode("RequiredMargin").InnerText = (requiredMargin + newOrderMaintMargin).ToString("#.##");
                    Convert.ToDecimal(requiredMargin + newOrderMaintMargin);
                }
                else
                {
                    // send order back to client 
                }
                doc.Save(@traderLog);
            }
            catch
            {
                Console.WriteLine("No trader with id: {0}", ID);  // send order back to client no account with clearing house
            }
            
        }

        static void tradeExecuted(ExecutedOrders newOrder)
        {
            double accountBalance;
            double requiredMargin;
            int curQuantity;
            double price;
            double newPrice;


            XmlDocument doc = new XmlDocument();
            //String traderLog = Environment.CurrentDirectory.ToString() + "\\clearingLog.xml"; can do this but would have to put the xml in bin folder
            String traderLog = ConfigurationManager.AppSettings["ClearingTraderLogPath"].ToString();
            doc.Load(@traderLog);
            String ID = newOrder.CustomerID.ToString();
            
            XmlNode traderNode = doc.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='" + ID + "']");



            if ((newOrder.OrderAction == "Delete" && newOrder.Status == "E") || newOrder.Status == "D") //E for executed D for denied
            {
                //remove order from trade log and update req margin
                curQuantity = Convert.ToInt32(traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Quantity").InnerText);
                price = Convert.ToDouble(traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Price").InnerText);
                newPrice = (price * curQuantity - newOrder.ExecutionQuantity * newOrder.LimitPrice) / (curQuantity - newOrder.ExecutionQuantity);

                traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Price").InnerText = newPrice.ToString("#.##");
                requiredMargin = Convert.ToDouble(traderNode.SelectSingleNode("RequiredMargin").InnerText);
                //traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.ExecutionPrice + "']/Quantity").InnerText = (newOrder.Quantity + curQuantity).ToString();

                requiredMargin = (requiredMargin - (newOrder.LimitPrice * newOrder.ExecutionQuantity) * Convert.ToDouble(ConfigurationManager.AppSettings["maintMargin"]));
                traderNode.SelectSingleNode("RequiredMargin").InnerText = (requiredMargin).ToString("#.##");

            }
            else 
            {
                accountBalance = Convert.ToDouble(traderNode.SelectSingleNode("Balance").InnerText);
                curQuantity = Convert.ToInt32(traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Quantity").InnerText);
                price = Convert.ToDouble(traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Price").InnerText);
                newPrice = (price * curQuantity - newOrder.ExecutionQuantity * (newOrder.LimitPrice - newOrder.ExecutionPrice)) / (curQuantity);

                traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.Instrument + "']/Price").InnerText = newPrice.ToString("#.##");
                requiredMargin = Convert.ToDouble(traderNode.SelectSingleNode("RequiredMargin").InnerText);
                //traderNode.SelectSingleNode("Positions/Ticker[@Ticker='" + newOrder.ExecutionPrice + "']/Quantity").InnerText = (newOrder.Quantity + curQuantity).ToString();

                requiredMargin = (requiredMargin + (newPrice - price) * newOrder.ExecutionQuantity);
                traderNode.SelectSingleNode("RequiredMargin").InnerText = (requiredMargin).ToString("#.##");


                if (accountBalance < requiredMargin)
                {//\
                    // do something here, either cancel order or ask for a deposit
                }
            }
            doc.Save(@traderLog);
            }

        public void updateTraderLog(Order newOrder) //not used for now
        {

            //XPathDocument document = new XPathDocument(@"C:\Users\Mike\Documents\Visual Studio 2012\Projects\Exchange\clearingLog.xml");
            //XPathNavigator navigator = document.CreateNavigator();
            //XmlNamespaceManager manager = new XmlNamespaceManager(navigator.NameTable);
            //manager.AddNamespace("bk", "http://www.contoso.com/books");

            ////XPathNavigator node = navigator.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='2']/Balance", manager);
            //navigator.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='2']/Balance", manager).SetValue("50");

            //document.Save(@"C:\Users\Mike\Documents\Visual Studio 2012\Projects\Exchange\clearingLog.xml");

            XmlDocument doc = new XmlDocument();
            //String traderLog = Environment.CurrentDirectory.ToString() + "\\clearingLog.xml"; can do this but would have to put the xml in bin folder
            String traderLog = ConfigurationManager.AppSettings["ClearingTraderLogPath"].ToString();
            doc.Load(@traderLog);
            doc.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='2']/Balance").InnerText = "56";

            doc.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='1']/Positions/Ticker[@Ticker='WFC']/Quantity").InnerText = "50";
            doc.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='2']/Positions/Ticker[@Ticker='BAC']/Quantity").InnerText = "50";
            try
            {
                doc.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='2']/Positions/Ticker[@Ticker='C']/Quantity").InnerText = "50";
            }
            catch
            {
                XmlElement quant = doc.CreateElement("Quantity");
                quant.InnerText = "0";
                XmlElement Ticker2 = doc.CreateElement("Ticker");

                Ticker2.SetAttribute("Ticker", "C");
                Ticker2.AppendChild(quant);
                doc.SelectSingleNode(@"ClearingCorpLog/Trader[@ID='2']/Positions").AppendChild(Ticker2);

            }
            doc.Save(@traderLog);

        }


    }
}
