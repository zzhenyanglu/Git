using System;
using System.Collections;
using client;


namespace server2
{
    public delegate void OrderEventHandler(object sender, OrderEventArgs e);


    public class OrderBook
    {
        public event OrderEventHandler OrderBeforeInsert;
        public event OrderEventHandler OrderInsert;
        public event OrderEventHandler StopToMarketEvent;//check stop order

        private IComparer orderPriority;
        private IComparer orderPriorityForMarket;

        private ContainerCollection bookRoot;
        public Hashtable ordersInProcess = new Hashtable();
        public static double marketPrice = 20;// market price; initiated to 20; updated after each match
        public double marketPrice2=20;//test
        public ContainerCollection Containers
        {
            get { return bookRoot; }
        }
        internal void OnStopToMarket(OrderEventArgs e)
        {
            if (StopToMarketEvent != null)
            {
                
                StopToMarketEvent(this, e);
            }
        }
        internal void OnOrderBeforeInsert(OrderEventArgs e)
        {
            if (OrderBeforeInsert != null)
            {
                //  Console.WriteLine("OrderBeforeInsert != null)");
                OrderBeforeInsert(this, e);
            }
        }
        internal void OnOrderInsert(OrderEventArgs e)
        {
            if (OrderInsert != null)
                OrderInsert(this, e);
        }
        public IComparer OrderPriority
        {
            get { return orderPriority; }
            set { orderPriority = value; }
        }

        public IComparer OrderPriorityForMarket
        {
            get { return orderPriorityForMarket; }
            set { orderPriorityForMarket = value; }
        }
        public OrderBook()
        {
            bookRoot = new ContainerCollection();
        }

        public void StopToMarket(object Order)
        {


            FuturesOrder order = (FuturesOrder)Order;
            //  OrderBook temp = new OrderBook();
            Container container = ProcessContainers(bookRoot, order.Instrument, order, null);
            container = ProcessContainers(container.ChildContainers, order.OrderType, order, container);
            if (container.ChildContainers.Exists(order.BuySell.ToString()) == false)
            {
                LeafContainer buyContainer = new LeafContainer(this, "B", container);
                LeafContainer sellContainer = new LeafContainer(this, "S", container);
                container.ChildContainers["B"] = buyContainer;
                container.ChildContainers["S"] = sellContainer;
            }
            LeafContainer leafContainer = container.ChildContainers[order.BuySell.ToString()] as LeafContainer;
          
            leafContainer.ProcessStopOrder(order);
        }
        private Container ProcessContainers(ContainerCollection contCollection, string name, Order order, Container parent)
        {
            if (contCollection.Exists(name) == false)
                contCollection[name] = new Container(this, name, parent);
               Container currentContainer = contCollection[name];
            //  currentContainer.ProcessOrder(order);
            return currentContainer;
        }
        public void Process(Order order)
        {

         
            Container container = ProcessContainers(bookRoot, order.Instrument, order, null);
          

            container = ProcessContainers(container.ChildContainers, order.OrderType, order, container);
         
            if (container.ChildContainers.Exists(order.BuySell.ToString()) == false)
            {
                LeafContainer buyContainer = new LeafContainer(this, "B", container);
                LeafContainer sellContainer = new LeafContainer(this, "S", container);
                container.ChildContainers["B"] = buyContainer;
                container.ChildContainers["S"] = sellContainer;
            }

       
            LeafContainer leafContainer = container.ChildContainers[order.BuySell.ToString()] as LeafContainer;


   

            leafContainer.ProcessOrder(order);
        }






    }
}
