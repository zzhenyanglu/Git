using System;
using System.Collections;
using System.Threading;


namespace OME.Storage
{
    public delegate void OrderEventHandler(object sender, OrderEventArgs e);
    

    public class OrderBook
    {
        public event OrderEventHandler OrderBeforeInsert;
        public event OrderEventHandler OrderInsert;
        
        private IComparer orderPriority;
        private ContainerCollection bookRoot;
        public Hashtable ordersInProcess = new Hashtable();
        

        public ContainerCollection Containers
        {
            get { return bookRoot; }
        }
        internal void OnOrderBeforeInsert(OrderEventArgs e)
        {
            if (OrderBeforeInsert != null)
                OrderBeforeInsert(this, e);
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
        public OrderBook()
        {
            bookRoot = new ContainerCollection();
        }
        private Container ProcessContainers(ContainerCollection contCollection, string name, Order order, Container parent)
        {
            if (contCollection.Exists(name) == false)
                contCollection[name] = new OME.Storage.Container(this, name, parent);
            OME.Storage.Container currentContainer = contCollection[name];
            currentContainer.ProcessOrder(order);
            return currentContainer;
        }
        public void Process(Order order)
        {
            Container container = ProcessContainers(bookRoot, order.Instrument, order, null);
            //container = ProcessContainers(container.ChildContainers, order.OrderType, order, container);
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
        public void ProcessStopOrder(Order order)
        {
            Container container = ProcessContainers(bookRoot, order.Instrument, order, null);
            //container = ProcessContainers(container.ChildContainers, order.OrderType, order, container);
            if (container.ChildContainers.Exists(order.BuySell.ToString()) == false)
            {
                LeafContainer buyContainer = new LeafContainer(this, "B", container);
                LeafContainer sellContainer = new LeafContainer(this, "S", container);
                container.ChildContainers["B"] = buyContainer;
                container.ChildContainers["S"] = sellContainer;
            }
            LeafContainer leafContainer = container.ChildContainers[order.BuySell.ToString()] as LeafContainer;
            leafContainer.useResourceAddStop(order);
        }

        public bool Delete(Order delorder)
        {
            bool orderDeleted;
            Container container = ProcessContainers(bookRoot, delorder.Instrument, delorder, null);
            //container = ProcessContainers(container.ChildContainers, order.OrderType, order, container);
            if (container.ChildContainers.Exists(delorder.BuySell.ToString()) == false)
            {
                LeafContainer buyContainer = new LeafContainer(this, "B", container);
                LeafContainer sellContainer = new LeafContainer(this, "S", container);
                container.ChildContainers["B"] = buyContainer;
                container.ChildContainers["S"] = sellContainer;
            }
            LeafContainer leafContainer = container.ChildContainers[delorder.BuySell.ToString()] as LeafContainer;
            if (leafContainer != null)
                {
                   orderDeleted = leafContainer.DeleteOrder(delorder);
                }
            else
               orderDeleted = false;

            return orderDeleted;
        }
    }
}
