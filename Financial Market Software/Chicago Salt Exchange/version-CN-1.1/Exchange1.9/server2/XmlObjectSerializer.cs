using System;
using System.Collections.Generic;

using System.Text;
using System.Reflection;
using System.Collections;
using System.ComponentModel;
using System.IO;
using System.Xml;
using System.Diagnostics;

namespace client
{
    /// <summary>
    /// Serialize objects from string and into string
    /// <para>This class use name and value method</para>
    /// </summary>
    public class XmlObjectSerializer
    {
        private XmlDocument xmlDoc;
        public XmlObjectSerializer()
        {

        }

        /// <summary>
        /// Serialize this object to string
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public XmlDocument Serialize(object obj,Type objectType=null)
        {
            if (objectType == null) objectType = obj.GetType();
            xmlDoc = new XmlDocument();
            xmlDoc.AppendChild(xmlDoc.CreateElement("XmlObjectSerializer"));
            xmlDoc.DocumentElement.Attributes.Append(xmlDoc.CreateAttribute("ObjectType")).Value = Utility.GetTypeFullName(objectType,null);
            SerializeProperty(obj, xmlDoc.DocumentElement);
            return xmlDoc;
        }

        /// <summary>
        /// Deserialize this txt to object
        /// </summary>
        /// <param name="xmlText"></param>
        /// <returns></returns>
        public object Deserialize(string xmlText, bool ThrowOnError = false)
        {
            xmlDoc = new XmlDocument();
            xmlDoc.LoadXml(xmlText);
            Type objectType = Utility.GetType(xmlDoc.DocumentElement.Attributes["ObjectType"].Value);
            var childs = GetChild(xmlDoc.DocumentElement);
            if (Utility.IsSimpleType(objectType))
                return xmlDoc.DocumentElement.InnerText.ConvertTo(objectType);
            else if (childs.Count > 0 && childs[0].Name == "Array")//Array found
                return DeserializeIEnumerable(childs[0], objectType, null, ThrowOnError);
            else
            {
                object obj = Utility.CreateInstance(objectType);
                DeserializeNode(xmlDoc.DocumentElement, obj, ThrowOnError);
                return obj;
            }
        }

        Dictionary<string, object> mapXPathNodeToObject = new Dictionary<string, object>();
        public void DeserializeNode(XmlNode node, object Instance, bool ThrowOnError = false)
        {
            mapXPathNodeToObject[Utility.GetXPath(node)] = Instance;
            foreach (XmlNode propertyNode in node.SelectNodes("Property"))
            {
                try
                {
                    MemberInfox propertyInfo = GetPropertyInfo(propertyNode, Instance);
                    object PropertyValue = propertyInfo.GetValue();
                    var childs = GetChild(propertyNode);
                    object refObj = CheckIfReferenceNode(propertyNode);
                    if (refObj != null)
                        propertyInfo.SetValue(refObj);
                    else if (Utility.IsSimpleType(propertyInfo.ValueType))//Simple property
                        SetPropertyValue(Instance, propertyNode);
                    else if (childs.Count > 0 && childs[0].Name == "Array")//Array found
                        propertyInfo.SetValue(DeserializeIEnumerable(childs[0], propertyInfo.ValueType, null, ThrowOnError));
                    else//Complex types
                    {
                        if (PropertyValue == null)
                        {
                            if (!Utility.TryCreateInstance(propertyInfo.ValueType, out PropertyValue)) continue;
                            propertyInfo.SetValue(PropertyValue);
                        }
                        DeserializeNode(propertyNode, PropertyValue, ThrowOnError);
                    }
                }
                catch { if (ThrowOnError)throw; }
            }
        }

        private IEnumerable DeserializeIEnumerable(XmlNode node, Type ArrayType, IEnumerable PropertyValue = null, bool ThrowOnError=false)
        {
            var itemsNodes = node.SelectNodes("Item");
            IEnumerable arrayObj = PropertyValue ?? Utility.CreateIEnumerable(ArrayType, itemsNodes.Count);
            mapXPathNodeToObject[Utility.GetXPath(node.ParentNode)] = arrayObj;
            var arrayObjItems = Utility.GetIEnumerableItems(arrayObj);

            var defaultNode = node.SelectSingleNode("ItemDefaults");
            int i = 0;
            foreach (XmlNode itemNode in itemsNodes)
            {
                Type elementType = GetElementDataType(itemNode, ArrayType);
                object elementObj = null;
                if (arrayObjItems.Count > i && arrayObjItems[i] != null && elementType == arrayObjItems[i].GetType())
                    elementObj = arrayObjItems[i];
                if (elementObj != null || Utility.TryCreateInstance(elementType, out elementObj))
                {
                    if (defaultNode != null) DeserializeNode(defaultNode, elementObj, ThrowOnError);
                    var childs = GetChild(itemNode);
                    var refObj = CheckIfReferenceNode(itemNode);
                    
                    if (refObj != null)
                        elementObj = refObj;
                    else if (Utility.IsSimpleType(elementType))
                        elementObj = itemNode.InnerText.ConvertTo(elementType);
                    else if (childs.Count == 0) ;
                    else if (childs[0].Name == "Array")//Element is also an array
                        elementObj = DeserializeIEnumerable(childs[0], elementType, null, ThrowOnError);
                    else DeserializeNode(itemNode, elementObj, ThrowOnError);
                    mapXPathNodeToObject[Utility.GetXPath(itemNode)] = elementObj;
                    Utility.SetIEnumerableElement(arrayObj, i, elementObj);
                }
                i++;
            }
            return arrayObj;
        }

        private object CheckIfReferenceNode(XmlNode node)
        {
            var refAtt = node.Attributes["ReferenceNode"];
            if (refAtt != null)
                return mapXPathNodeToObject[refAtt.Value];
            return null;
        }

        private MemberInfox GetPropertyInfo(XmlNode propertyNode, object obj)
        {
            if (propertyNode.Attributes["PropertyName"] == null) return null;
            string name = propertyNode.Attributes["PropertyName"].Value;
            var propX = Utility.GetPropertyInfox(obj, name);
            if (!propX.MemberExists)
                throw new Exception("Property " + name + " does not exists.");
            if (propertyNode.Attributes["PropertyDataType"] != null)
            {
                var vType = Utility.GetType(propertyNode.Attributes["PropertyDataType"].Value, propX.MemberType);
                if (propX.ValueType != vType)
                {
                    propX.ValueType = vType;
                    propX.SetValue(Utility.GetDefault(vType));
                }
            }
            return propX;
        }
        private Type GetElementDataType(XmlNode elementNode, Type ArrayType)
        {
            Type elementType = null;
            if (elementNode.Attributes["ElementDataType"] != null)
                elementType = Utility.GetType(elementNode.Attributes["ElementDataType"].Value, Utility.GetElementType(ArrayType));
            return elementType ?? Utility.GetElementType(ArrayType);
        }
        private void SetPropertyValue(object obj, XmlNode propertyNode)
        {
            MemberInfox property = GetPropertyInfo(propertyNode, obj);
            if (property == null) return;
            property.SetValue(propertyNode.InnerText.Trim().ConvertTo(property.ValueType));
        }


        Dictionary<object, XmlNode> MapObjectToNode = new Dictionary<object, XmlNode>();
        private void SerializeProperty(object propertyValue, XmlNode node)
        {
            if (propertyValue == null) return;
            Type propertyType = propertyValue.GetType();
            if (Utility.IsSimpleType(propertyType))
                node.InnerText = propertyValue.ConvertTo<string>();
            else
            {
                if (MapObjectToNode.ContainsKey(propertyValue))//Prevent looping exceptions, when the instance refer to its self
                {
                    node.Attributes.Append(xmlDoc.CreateAttribute("ReferenceNode")).Value =Utility.GetXPath( MapObjectToNode[propertyValue]);
                    return;
                }
                else MapObjectToNode[propertyValue] = node;
                if (Utility.IsIEnumerable(propertyType))
                {
                    var elmentType = Utility.GetElementType(propertyValue.GetType());
                    XmlElement arrayNode = (XmlElement)node.AppendChild(xmlDoc.CreateElement("Array"));

                    foreach (var item in Utility.GetIEnumerableItems(propertyValue))
                    {
                        var elementNode = arrayNode.AppendChild(xmlDoc.CreateElement("Item"));
                        if (item != null && elmentType.GetUnderlyingType() != item.GetType().GetUnderlyingType())
                            elementNode.Attributes.Append(xmlDoc.CreateAttribute("ElementDataType")).Value = Utility.GetTypeFullName(item.GetType(), elmentType);
                        SerializeProperty(item, elementNode);
                    }
                    ExtractSharedValues(arrayNode);
                }
                else//Complex types, such as OlvFormSpec.Button
                {
                    int childs = node.ChildNodes.Count;
                    foreach (var propx in MemberInfox.GetMemberInfox(propertyValue))
                    {
                        var att = propx.GetCustomAttributes(typeof(ObjectSerializerAttribute)) as ObjectSerializerAttribute;
                        if (att != null && att.DontSerialize) 
                            continue;
                        if (IsEqualDefaut(propx)) continue;
                        var propertyNode = node.AppendChild(xmlDoc.CreateElement("Property"));
                        propertyNode.Attributes.Append(xmlDoc.CreateAttribute("PropertyName")).Value = propx.Name;
                        if (propx.MemberType.GetUnderlyingType() != propx.ValueType.GetUnderlyingType())
                            propertyNode.Attributes.Append(xmlDoc.CreateAttribute("PropertyDataType")).Value = Utility.GetTypeFullName(propx.ValueType, propx.MemberType);
                        SerializeProperty(propx.GetValue(), propertyNode);
                        if (propertyNode.ChildNodes.Count == 0 && propertyNode.Attributes.Count < 2)//No need for complex object without having inner nodes
                            node.RemoveChild(propertyNode);
                    }
                    if (node.ChildNodes.Count == childs)
                        MapObjectToNode.Remove(propertyValue);
                }
            }
        }

        private bool IsEqualDefaut(MemberInfox property)
        {
            try
            {
                if (!Utility.IsSimpleType(property.ValueType))
                    return false;
                var val = property.GetValue();
                object att = property.GetCustomAttributes(typeof(DefaultValueAttribute));
                if (att != null)
                    return object.Equals(val, (att as DefaultValueAttribute).Value);
                return object.Equals(val, Utility.GetDefault(property.MemberType));
            }
            catch {  }
            return true;
        }

        private void ExtractSharedValues(XmlElement arrayNode)
        {
            var childs = GetChild(arrayNode);
            if (childs.Count < 2) return;//No defaults for less than two item in the array
            if (arrayNode.SelectNodes("Item[@ElementDataType]").Count > 0)//Dont make default for different Data types
                return;
            Dictionary<string, int> dic = new Dictionary<string, int>();
            Dictionary<string, string> propertyValue = new Dictionary<string, string>();
            foreach (XmlNode property in arrayNode.SelectNodes("Item/Property"))
            {
                string key = property.Attributes["PropertyName"].Value;
                if (propertyValue.ContainsKey(key) && propertyValue[key] != property.InnerXml)
                    dic.Remove(key);
                else
                {
                    propertyValue[key] = property.InnerXml;
                    if (dic.ContainsKey(key)) dic[key]++;
                    else dic[key] = 1;
                }
            }
            var defaultItem = xmlDoc.CreateElement("ItemDefaults");

            foreach (var item in dic)
            {
                if (item.Value < childs.Count) continue;
                var nodes = arrayNode.SelectNodes(string.Format("Item/Property[@PropertyName=\"{0}\"]", item.Key));
                foreach (XmlNode node in nodes)
                    node.ParentNode.RemoveChild(node);
                defaultItem.AppendChild(nodes[0]);
            }
            if (GetChild(defaultItem).Count > 0)
                arrayNode.InsertBefore(defaultItem, childs[0]);
        }

        private List<XmlElement> GetChild(XmlNode parent)
        {
            List<XmlElement> list = new List<XmlElement>();
            foreach (XmlNode item in parent.ChildNodes)
            {
                if (item is XmlElement)
                    list.Add(item as XmlElement);
            }
            return list;
        }
        /// <summary>
        /// Checks if the object has all properties as the default values.
        /// </summary>
        /// <returns></returns>
        public static bool IsEmptyObject(object obj)
        {
            try { return obj == null || new XmlObjectSerializer().Serialize(obj).DocumentElement.ChildNodes.Count == 0; }
            catch { return false; }
        }
        /// <summary>
        /// Clone this object by Serialize and Deserialize methods
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public static object Clone(object obj)
        {
            XmlObjectSerializer xml = new XmlObjectSerializer();
            string s = xml.Serialize(obj).OuterXml;
            return xml.Deserialize(s);
        }
    }

    public class ObjectSerializerAttribute : Attribute
    {
        /// <summary>
        /// Determine if the End User can Edit this property in PropertyGrid control
        /// </summary>
        public bool CanEdit { get; set; }

        /// <summary>
        /// Should Serialize this property or not
        /// </summary>
        public bool DontSerialize { get; set; }

        /// <summary>
        /// CanEndUserEditThis?
        /// </summary>
        public bool CanEndUserEditThis { get; set; }

        ///// <summary>
        ///// Gets or Sets the Priority of this property, this Priority calculated for the highest value
        ///// </summary>
        //public int SerializePriority { get; set; }
        public ObjectSerializerAttribute()
        {
            this.CanEdit = true;
            DontSerialize = false;
        }
    }
}
