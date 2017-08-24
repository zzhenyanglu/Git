using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using System.ComponentModel;
using System.Reflection;
using System.Xml;
using System.Text.RegularExpressions;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;

using System.Windows;
using System.Data;

using System.Security.Permissions;

namespace client
{
    public class Utility
    {
        /// <summary>
        /// Store the user's defined type converters, use this to add converter for un supporetd types such as BitmapFrameConverter and TypeTypeConverter
        /// </summary>
        public static Dictionary<Type, TypeConverter> StaticConverters = new Dictionary<Type, TypeConverter>();

        static Utility()
        {
            StaticConverters[typeof(Type)] = new TypeTypeConverter();
        }
        #region XPath
        public static bool IsNullOrWhiteSpace(string txt)
        {
            return txt == null || txt.Trim() == "";
        }

        public static String FormatXML(XmlNode node)
        {
            String Result = "";

            MemoryStream mStream = new MemoryStream();
            XmlTextWriter writer = new XmlTextWriter(mStream, Encoding.Unicode);

            try
            {
                writer.Formatting = Formatting.Indented;

                // Write the XML into a formatting XmlTextWriter
                node.WriteContentTo(writer);
                writer.Flush();
                mStream.Flush();

                // Have to rewind the MemoryStream in order to read
                // its contents.
                mStream.Position = 0;

                // Read MemoryStream contents into a StreamReader.
                StreamReader sReader = new StreamReader(mStream);

                // Extract the text from the StreamReader.
                String FormattedXML = sReader.ReadToEnd();

                Result = FormattedXML;
            }
            catch (XmlException)
            {
                Result = node.InnerXml;
            }
            writer.Close();

            return Result;
        }
        public static string GetXPath(XmlNode node)
        {
            StringBuilder builder = new StringBuilder();
            while (node != null)
            {
                switch (node.NodeType)
                {
                    case XmlNodeType.Attribute:
                        builder.Insert(0, "/@" + node.Name);
                        node = ((XmlAttribute)node).OwnerElement;
                        break;
                    case XmlNodeType.Element:
                        if (node.Attributes["PropertyName"] != null)
                            builder.Insert(0, "/" + node.Name + "[@PropertyName='" + node.Attributes["PropertyName"].Value + "']");
                        else
                        {
                            int index = FindElementIndex((XmlElement)node);
                            builder.Insert(0, "/" + node.Name + "[" + index + "]");
                        }
                        node = node.ParentNode;
                        break;
                    case XmlNodeType.Document:
                        return builder.ToString();
                    default:
                        throw new ArgumentException("Only elements and attributes are supported");
                }
            }
            throw new ArgumentException("Node was not in a document");
        }

        static int FindElementIndex(XmlElement element)
        {
            XmlNode parentNode = element.ParentNode;
            if (parentNode is XmlDocument)
            {
                return 1;
            }
            XmlElement parent = (XmlElement)parentNode;
            int index = 1;
            foreach (XmlNode candidate in parent.ChildNodes)
            {
                if (candidate is XmlElement && candidate.Name == element.Name)
                {
                    if (candidate == element)
                    {
                        return index;
                    }
                    index++;
                }
            }
            throw new ArgumentException("Couldn't find element within parent");
        }
        #endregion

        #region Other methods

       public static bool IsWinXPOrHigher()
        {
            OperatingSystem OS = Environment.OSVersion;
            return (OS.Platform == PlatformID.Win32NT) && ((OS.Version.Major > 5) || ((OS.Version.Major == 5) && (OS.Version.Minor >= 1)));
        }

       public static bool IsWinVistaOrHigher()
        {
            OperatingSystem OS = Environment.OSVersion;
            return (OS.Platform == PlatformID.Win32NT) && (OS.Version.Major >= 6);
        }


        private static string executablePath;
        /// <summary>
        /// Gets the Exe Path
        /// </summary>
        public static string ExecutablePath
        {
            get
            {
                if (executablePath == null)
                {
                    string escapedCodeBase = Assembly.GetEntryAssembly().EscapedCodeBase;
                    Uri uri = new Uri(escapedCodeBase);
                    if (uri.Scheme == "file")
                        executablePath = new Uri(escapedCodeBase).LocalPath;
                    else executablePath = uri.ToString();
                }
                return executablePath;
            }
        }
        /// <summary>
        /// Gets the Directory that contains the Exe
        /// </summary>
        public static string StartupPath
        {
            get { return Path.GetDirectoryName(ExecutablePath); }
        }
        /// <summary>
        /// Build the DataTable that contains the Properties of item
        /// </summary>
        public static DataTable BuildOneRowDataTable(object item)
        {
            DataTable table = new DataTable();
            var itemType = item.GetType();
            List<object> propertiesValues = new List<object>();
            foreach (var p in itemType.GetProperties())
            {
                if (p.GetIndexParameters().Length > 0) continue;
                table.Columns.Add(p.Name, p.PropertyType);
                propertiesValues.Add(p.GetValue(item, null));
            }
            if (!table.Columns.Contains("Value"))
            {
                propertiesValues.Add(item);
                table.Columns.Add("Value", item.GetType());
            }
            table.Rows.Add(propertiesValues.ToArray());
            return table;
        }


        /// <summary>
        /// Gets all types that inherited from this interface
        /// </summary>
        /// <param name="InterfaceType"></param>
        /// <returns></returns>
        public static List<Type> GetAllTypes(Type InterfaceType, bool IncludeInterfaces = true, bool IncludeAbstractClasses = true, bool IncludeEnums = true, bool IncludeDelegates = true, bool IncludeGeneric = true, bool IncludeExceptions = true, bool IncludeAttributes = true, bool IncludeNotPublic = false)
        {
            List<Type> types = new List<Type>();
            foreach (var ass in AppDomain.CurrentDomain.GetAssemblies())
                foreach (var type in ass.GetTypes())
                {
                    if (type.Name.Contains("$") || !char.IsLetter(type.Name[0])) continue;
                    if (InterfaceType != null && !InterfaceType.IsAssignableFrom(type)) continue;
                    if (!IncludeInterfaces && type.IsInterface) continue;
                    if (!IncludeAbstractClasses && type.IsAbstract) continue;
                    if (!IncludeEnums && type.IsEnumType()) continue;
                    if (!IncludeDelegates && typeof(Delegate).IsAssignableFrom(type)) continue;
                    if (!IncludeDelegates && typeof(EventArgs).IsAssignableFrom(type)) continue;
                    if (!IncludeGeneric && (type.IsGenericType || type.IsGenericTypeDefinition)) continue;
                    if (!IncludeExceptions && typeof(Exception).IsAssignableFrom(type)) continue;
                    if (!IncludeAttributes && typeof(Attribute).IsAssignableFrom(type)) continue;
                    if (!IncludeNotPublic && type.IsNotPublic) continue;
                    types.Add(type);
                }
            return types;
        }


        public static string Replace(string text, string replace, string replaceBy, RegexOptions RegexOptions = RegexOptions.IgnoreCase)
        {
            if (Utility.IsNullOrWhiteSpace(text)) return text;
            var regex = new Regex(replace, RegexOptions);
            return regex.Replace(text, replaceBy);
        }

        public static int GetIEnumerableItemsCount(IEnumerable iEnumerable)
        {
            if (iEnumerable is Array)
                return (iEnumerable as Array).Length;
            try { return (int)GetPropertyInfox(iEnumerable, "Count").GetValue(); }
            catch
            {

                try { return (int)GetPropertyInfox(iEnumerable, "Length").GetValue(); }
                catch { return GetIEnumerableItems(iEnumerable).Count; }
            }
        }
        public static IEnumerable CreateIEnumerable(Type IEnumerableType, int ItemsCountIfArray)
        {
            IEnumerable list;
            if (IEnumerableType.IsArray)
            {
                Type elementType = GetElementType(IEnumerableType);
                list = Array.CreateInstance(elementType, ItemsCountIfArray);
            }
            else list = Utility.CreateInstance(IEnumerableType) as IEnumerable;
            return list;
        }
        public static bool IsIEnumerable(Type type)
        {
            return type != typeof(string) && typeof(IEnumerable).IsAssignableFrom(type);
        }
        public static ArrayList GetIEnumerableItems(object list)
        {
            ArrayList items = new ArrayList();
            if (list is IDictionary)
                foreach (var item in (list as IDictionary))
                    items.Add(item);
            else foreach (var item in (list as IEnumerable))
                    items.Add(item);
            return items;
        }
        public static void SetIEnumerableElement(IEnumerable list, int IndexIfFixedSize, object value)
        {
            if (list is IDictionary)
            {
                var t = GetElementType(list.GetType());
                object Dkey = GetPropertyInfox(value, "Key").GetValue();
                object DValue = GetPropertyInfox(value, "Value").GetValue();
                (list as IDictionary)[Dkey] = DValue;
            }
            else if (list is IList)
            {
                if ((list as IList).Count - 1 >= IndexIfFixedSize)
                    (list as IList)[IndexIfFixedSize] = value;
                else if ((list as IList).IsFixedSize)
                    (list as IList)[IndexIfFixedSize] = value;
                else (list as IList).Add(value);
            }
            else
            {
                var type = value == null ? typeof(object) : value.GetType();
                MethodInfo AddMethod = null;
                foreach (var m in list.GetType().GetMethods())
                {
                    if (m.Name != "Add" || m.GetParameters().Length != 1 || !m.GetParameters()[0].ParameterType.IsAssignableFrom(type))
                        continue;
                    AddMethod = m;
                    break;
                }
                if (AddMethod != null)
                    AddMethod.Invoke(list, new object[] { value });
            }
        }
        #endregion

        #region Type utility
        private static Dictionary<string, Type> AssembliesTypes = new Dictionary<string, Type>(StringComparer.InvariantCultureIgnoreCase);
        private static void hashAssembliesTypes()
        {
            if (AssembliesTypes.Count > 0) return;
            foreach (var z in AppDomain.CurrentDomain.GetAssemblies())
                foreach (var item in z.GetTypes())
                    AssembliesTypes[item.FullName] = item;
        }
        /// <summary>
        /// Gets the Type from it's name
        /// </summary>
        public static Type GetType(string TypeName, Type BaseType = null, bool ThrowOnError = false, bool IqnoreCase = true)
        {
            try
            {
                if (TypeName.EndsWith(">"))
                {
                    var nameAndArgs = TypeName.Split(new char[1] { '<' }, 2);
                    var defType = GetType(nameAndArgs[0], BaseType, ThrowOnError, IqnoreCase);
                    List<Type> argsTypes = new List<Type>();
                    foreach (var item in nameAndArgs[1].TrimEnd('>').Split('|'))
                        argsTypes.Add(GetType(item, BaseType, ThrowOnError, IqnoreCase));
                    return defType.MakeGenericType(argsTypes.ToArray());
                }
            }
            catch { }
            if (BaseType != null)
            {
                if (!TypeName.Contains("."))//Type namespace not found
                    TypeName = BaseType.Namespace + "." + TypeName;
                return BaseType.Assembly.GetType(TypeName) ?? GetType(TypeName, null, ThrowOnError, IqnoreCase);
            }
            var t = Type.GetType(TypeName, ThrowOnError, IqnoreCase);
            if (t != null) return t;
            hashAssembliesTypes();
            if (AssembliesTypes.ContainsKey(TypeName))
                t = AssembliesTypes[TypeName];
            return t;
        }

        public static string GetTypeFullName(Type type, Type BaseType, bool SimplifyGenericType = true)
        {
            if (SimplifyGenericType && type.IsGenericType && !type.IsGenericTypeDefinition)
            {
                string txt = GetTypeFullName(type.GetGenericTypeDefinition(), BaseType) + "<";
                foreach (var item in type.GetGenericArguments())
                    txt += GetTypeFullName(item, null, false) + "|";
                return txt.TrimEnd('|') + ">";
            }
            if (GetType(type.FullName, BaseType) != null)
                return BaseType != null && type.Namespace == BaseType.Namespace ? type.Name : type.FullName;
            else return type.AssemblyQualifiedName;
        }
        private static Dictionary<string, object> getDefaults = new Dictionary<string, object>();
        public static object GetDefault(Type type)
        {
            if (getDefaults.ContainsKey(type.FullName))
                return getDefaults[type.FullName];
            if (type.IsValueType)
                return getDefaults[type.FullName] = Utility.CreateInstance(type);
            return null;
        }
        public static object CreateInstance(Type type)
        {
            if (type == null || type.IsAbstract || type.IsInterface)
                return null;
            if (type == typeof(string)) return "";
            try { return Activator.CreateInstance(type); }
            catch (Exception ex)
            {
                foreach (var constructor in type.GetConstructors((BindingFlags)0xfff))
                {
                    try
                    {
                        List<object> parameters = new List<object>();
                        foreach (var item in constructor.GetParameters())
                            parameters.Add(GetDefault(item.ParameterType));
                        return constructor.Invoke(parameters.ToArray());
                    }
                    catch { }
                }
                throw ex;
            }
        }

        public static object CreateInstance(Type GenericTypeDefinition, params Type[] GenericTypes)
        {
            if (GenericTypeDefinition == null || !GenericTypeDefinition.IsGenericTypeDefinition || GenericTypes.Length != GenericTypeDefinition.GetGenericArguments().Length)
                return null;
            return CreateInstance(GenericTypeDefinition.MakeGenericType(GenericTypes));
        }

        public static bool TryCreateInstance(Type type, out object createdObject)
        {
            try { createdObject = CreateInstance(type); return true; }
            catch { createdObject = null; return false; }
        }
        public static MemberInfox GetPropertyInfox(object obj, string PropertyPath, bool SearchForPriviteFieldInCasePublicFieldIsReadOnly = true)
        {
            MemberInfox info = null;
            foreach (var partName in (PropertyPath + "").Split('.'))//For nested properties like a.Name
            {
                info = new MemberInfox(obj, partName, SearchForPriviteFieldInCasePublicFieldIsReadOnly);
                if (!info.MemberExists) return info;
                obj = info.GetValue();
            }
            return info;
        }

        private static Dictionary<string, MemberInfo> cachGetMemberInfo = new Dictionary<string, MemberInfo>();
        public static MemberInfo GetMemberInfo(Type objType, string memberName, bool SearchForPriviteFieldInCasePublicFieldIsReadOnly = true)
        {
            if (objType == null) return null;

            string key = objType.AssemblyQualifiedName + "." + memberName + "[" + SearchForPriviteFieldInCasePublicFieldIsReadOnly + "]";
            if (cachGetMemberInfo.ContainsKey(key))
                return cachGetMemberInfo[key];

            MemberInfo member = objType.GetProperty(memberName, (BindingFlags)0xfff) ?? objType.GetProperty(memberName);
            if (SearchForPriviteFieldInCasePublicFieldIsReadOnly)
            {
                if (member == null || (member as PropertyInfo).GetSetMethod() == null || (member as PropertyInfo).GetGetMethod() == null)//we dont need properties without gets or set methods
                {
                    MemberInfo tryField = objType.GetField(memberName, (BindingFlags)0xfff) ?? objType.GetField(memberName);
                    if (tryField == null)
                        tryField = objType.GetField("_" + memberName, (BindingFlags)0xfff) ?? objType.GetField("_" + memberName);
                    if (tryField != null)
                        member = tryField;
                }
            }
            return cachGetMemberInfo[key] = member;
        }
        public static bool IsSimpleType(Type propertyType)
        {
            propertyType = propertyType.GetUnderlyingType();
            var code = Type.GetTypeCode(propertyType);
            if (code != TypeCode.Object && code != TypeCode.Empty)
                return true;
            if (typeof(IList).IsAssignableFrom(propertyType))
            {
                var type = GetElementType(propertyType);
                if (type == null) return false;
                propertyType = type;
                code = Type.GetTypeCode(propertyType);
                if (code != TypeCode.Object && code != TypeCode.Empty)
                    return true;
            }

            var converter = GetConverter(propertyType, false);
            if (converter == null) return false;
            else return converter.CanConvertFrom(typeof(string));
        }
        public static TypeConverter GetConverter(Type type, bool Inherit = true)
        {
            TypeConverter converter=null;
            foreach (var item in StaticConverters)
            {
                if (!item.Key.IsAssignableFrom(type)) continue;
                converter = item.Value;
                break;
            }
            if (converter != null)
                return converter;

            if (!Inherit)
            {
                var attributes = type.GetCustomAttributes(typeof(TypeConverterAttribute), false);
                if (attributes != null && attributes.Length > 0)
                {
                    var att = attributes[0] as TypeConverterAttribute;
                    return CreateInstance(Type.GetType(att.ConverterTypeName)) as TypeConverter;
                }
                else return null;
            }
            else return TypeDescriptor.GetConverter(type);
        }
        /// <summary>
        /// Make chunks from the big array
        /// </summary>
        /// <param name="Keys"></param> 
        public static IEnumerable<Array> MakeChunks(Array SourceArray, int ChunkLength)
        {
            for (int i = 0; i < SourceArray.Length; i += ChunkLength)
            {
                int length = Math.Min(ChunkLength, SourceArray.Length - i);
                Array chunk = Array.CreateInstance(SourceArray.GetType().GetElementType(), length);
                Array.Copy(SourceArray, i, chunk, 0, length);
                yield return chunk;
            }
        }
        public static Type GetElementType(Type IEnumerableType)
        {
            if (!typeof(IEnumerable).IsAssignableFrom(IEnumerableType))
                return null;

            if (IEnumerableType.IsArray)
                return IEnumerableType.GetElementType();
            Type[] genericParameters;
            foreach (var interfaceType in IEnumerableType.GetInterfaces())
            {
                if (!interfaceType.IsGenericType) continue;
                genericParameters = interfaceType.GetGenericArguments();
                if (genericParameters.Length == 1)
                    return genericParameters[0];
            }
            if (IEnumerableType.IsGenericType)
            {
                genericParameters = IEnumerableType.GetGenericArguments();
                if (genericParameters.Length == 1)
                    return genericParameters[0];
            }
            var addMethod = IEnumerableType.GetMethod("Add");
            if (addMethod != null && addMethod.GetParameters().Length == 1)
                return addMethod.GetParameters()[0].ParameterType;
            return typeof(object);
        }
        #endregion

        #region julian Dates
        const int ORIGIN_JULIAN = 2299238;
        static DateTime ORIGIN_Date = new DateTime(1582, 12, 30, 23, 59, 59, 999);
        public static double ToJulianDate(DateTime date)
        {
            return (date - ORIGIN_Date).TotalDays + ORIGIN_JULIAN - 0.50000001;
        }
        public static DateTime FromJulianDate(double jDate)
        {
            return ORIGIN_Date.AddDays(jDate - ORIGIN_JULIAN + 0.5);
        }
        #endregion

        #region Convert type to type
        /// <summary>
        /// Serialize the array elements as item1,item2,item3
        /// </summary>
        public static string SerializeArrayAsString(IList list)
        {
            StringBuilder txt = new StringBuilder();
            foreach (var item in list)
                txt.Append("\"" + item + "\",");
            if (txt.Length > 0)
                txt.Remove(txt.Length - 1, 1);
            return txt.ToString();
        }
        /// <summary>
        /// DeSerialize array items from string as item1,item2,item3,..
        /// </summary>
        public static IList DeSerializeArrayFromString(Type ArrayType, string value)
        {
            string[] data = value.Split(',');
            IList list = CreateIEnumerable(ArrayType, data.Length) as IList;
            Type elementType = GetElementType(ArrayType);
            for (int i = 0; i < data.Length; i++)
                SetIEnumerableElement(list, i, data[i].Trim('"').ConvertTo(elementType));
            return list;
        }
        public static string Tabs(int count)
        {
            if (count <= 0) return "";
            return new string('\t', count);
        }
        /// <summary>
        /// Convert the byte[] to String value
        /// </summary>
        /// <param name="data">The byte[] data</param>
        /// <returns></returns>
        public static string GetString(byte[] data)
        {
            if (data == null) return null;
            return System.Text.Encoding.ASCII.GetString(data).Trim('\0');
        }
        /// <summary>
        /// Convert the string value to byte[]
        /// </summary>
        /// <param name="data">The input string value</param>
        /// <returns></returns>
        public static byte[] GetBytes(string data, int arrayLength = -1)
        {
            if (data == null) data = "";
            var bytes = System.Text.Encoding.ASCII.GetBytes(data);
            if (arrayLength == -1) return bytes;
            var sizedBytes = new byte[arrayLength];
            bytes.CopyTo(sizedBytes, 0);
            return sizedBytes;
        }
        /// <summary>
        /// Sets the input string as byte[] to this property
        /// </summary>
        public static void SetAsBytes(string data, object obj, string propertyName)
        {
            var property = GetPropertyInfox(obj, propertyName);
            property.SetValue(GetBytes(data, GetSizeConst(property)));
        }

        public static int GetSizeConst(MemberInfox property)
        {
            var att = property.GetCustomAttributes(typeof(MarshalAsAttribute)) as MarshalAsAttribute;
            if (att == null) return -1;
            return att.SizeConst;
        }
        /// <summary>
        /// Convert the char[] data to string value
        /// </summary>
        /// <param name="data">The input char[]</param>
        /// <returns></returns>
        public static string GetString(char[] data)
        {
            return new string(data).Trim('\0');
        }
        /// <summary>
        /// Convert the string value to char[]
        /// </summary>
        /// <param name="data">The input string value</param>
        /// <returns></returns>
        public static char[] GetChars(string data)
        {
            return data.ToCharArray();
        }


        /// <summary>
        /// Convert the integer value to DataTime instance
        /// <para>The interger format must have the year in the first 5 digits, the month in the next two digits, the day in the last two digits</para>
        /// <example>20121022 means 2012/10/22</example>
        /// </summary>
        /// <param name="DateValue">The input integer value</param>
        /// <returns></returns>
        public static DateTime ReadYearMonthDayFromInteger(int DateValue)
        {
            if (DateValue == 0) return new DateTime();
            int l = DateValue.ToString().Length;
            if (l != 8) throw new InvalidProgramException("Time Value must be 8 digits.");

            int year = DateValue / 10000;
            int month = (DateValue / 100) % 100;
            int day = DateValue % 100;
            return new DateTime(year, month, day);

        }
        /// <summary>
        /// Conver the DataTime instance to ineger value
        /// <example>2012/10/22 will be converted to 20121022</example>
        /// </summary>
        /// <param name="DateTime">The input DataTime instance</param>
        /// <returns></returns>
        public static int GetYearMonthDayAsInteger(DateTime DateTime)
        {
            int value = DateTime.Year * 10000 + DateTime.Month * 100 + DateTime.Day;
            return value;
        }

        /// <summary>
        /// Convert integer value to Time
        /// <para>The interger format must have the hours in the first two digits, the minutes in the next two digits</para>
        /// <example>1023 means 10:23</example>
        /// </summary>
        /// <param name="TimeValue">The input integer value</param>
        /// <returns></returns>
        public static DateTime ReadHourMinFromInteger(int TimeValue)
        {
            if (TimeValue == 0) return new DateTime();
            int l = TimeValue.ToString().Length;
            if (l > 4 || l < 3) throw new InvalidProgramException("Time Value must be 4 digits.");
            return new DateTime(2012, 1, 1, TimeValue / 100, TimeValue % 100, 0);
        }
        /// <summary>
        /// Convert Time to integer
        /// <example>10:23 will be converted into 1023</example>
        /// </summary>
        /// <param name="TimeValue"></param>
        /// <returns></returns>
        public static int GetHourMinAsInteger(DateTime TimeValue)
        {
            return TimeValue.Hour * 100 + TimeValue.Minute;
        }

        public static string FormatTimeToHoursMinutes(string time)
        {
            if (time.Length == 3)
                return time[0] + ":" + time[1] + time[2];
            else if (time.Length == 4)
                return time[0] + time[1] + ":" + time[2] + time[3];
            else return time;
        }
        #endregion


        #region Property Descriptor
    
        private static Dictionary<Type, List<PropertyDescriptor>> PropertyDescriptorsBuffer = new Dictionary<Type, List<PropertyDescriptor>>();
        /// <summary>
        /// Gets the PropertyDescriptors for this Type
        /// </summary>
        public static List<PropertyDescriptor> GetPropertyDescriptors(Type ObjectType)
        {
            if (PropertyDescriptorsBuffer.ContainsKey(ObjectType))
                return PropertyDescriptorsBuffer[ObjectType];
            List<PropertyDescriptor> members = new List<PropertyDescriptor>();
            if (ObjectType == null) return members;
            var type = ObjectType;
            while (type != null && type != typeof(object))
            {
                foreach (PropertyDescriptor prop in TypeDescriptor.GetProperties(type))
                {
                    if (members.Exists(m => m.Name == prop.Name)) continue;
                    try { type.GetProperty(prop.Name); }
                    catch { continue; }
                    members.Add(prop);
                }
                type = type.BaseType;
            }
            return PropertyDescriptorsBuffer[ObjectType] = members;

        }
        /// <summary>
        /// Create a PropertyDescriptor
        /// </summary>
        public static PropertyDescriptor CreatePropertyDescriptor(Type OwnerType, Type PropertyType, string Name, string DisplayName, bool IsReadOnly)
        {
            if (string.IsNullOrEmpty(DisplayName))
                DisplayName = Name;
            return TypeDescriptor.CreateProperty(OwnerType, Name, PropertyType, new DisplayNameAttribute(DisplayName), new ReadOnlyAttribute(IsReadOnly));
        }
        private class IEnumerableContainer
        {

        }
        /// <summary>
        /// Create a PropertyDescriptor
        /// </summary>
        public static PropertyDescriptor CreateIEnumerablePropertyDescriptor(Type PropertyType, string Name, string DisplayName, bool IsReadOnly)
        {
            return CreatePropertyDescriptor(typeof(IEnumerableContainer), PropertyType, Name, DisplayName, IsReadOnly);
        }

        /// <summary>
        /// Gets an object of the same type as Instances, this object carry only the shared properties values between all the Instances.
        /// </summary>
        public static object GetSharedPropertiesValuesInstance(IList Instances)
        {
            if (Instances.Count == 0) return null;
            var objType = Instances[0].GetType();
            object obj = Utility.CreateInstance(objType);
            foreach (PropertyDescriptor prop in TypeDescriptor.GetProperties(obj))
            {
                var propx = Utility.GetPropertyInfox(obj, prop.Name, false);
                if (propx == null || !propx.MemberExists || !propx.CanRead || !propx.CanWrite)
                    continue;
                if (IsValueShared(prop.Name, Instances))
                    propx.SetValue(prop.GetValue(Instances[0]));
                else
                {
                    var sharedType = GetSharedType(prop.Name, Instances) ?? prop.PropertyType;
                    try { propx.SetValue(Utility.IsSimpleType(sharedType) ? Utility.GetDefault(sharedType) : Utility.CreateInstance(sharedType)); }
                    catch { propx.SetValue(Utility.GetDefault(sharedType)); }
                }
            }
            return obj;
        }
        private static bool IsValueShared(string PropertyName, IList Instances)
        {
            object sharedValue = null;
            for (int i = 0; i < Instances.Count; i++)
            {
                var p = Utility.GetPropertyInfox(Instances[i], PropertyName, false);
                object value;
                if (p == null || !p.MemberExists)
                    value = null;
                else value = p.GetValue();
                if (i == 0)
                    sharedValue = value;
                else if (!object.Equals(sharedValue, value))
                    return false;
            }
            return true;
        }

        private static Type GetSharedType(string PropertyName, IList Instances)
        {
            Type sharedType = null;
            for (int i = 0; i < Instances.Count; i++)
            {
                var p = Utility.GetPropertyInfox(Instances[i], PropertyName, false);
                Type type;
                if (p == null || !p.MemberExists)
                    type = null;
                else type = p.ValueType;
                if (i == 0)
                    sharedType = type;
                else
                {
                    sharedType = GetSharedBaseType(sharedType, type);
                    if (sharedType == null)
                        break;
                }
            }
            return sharedType;
        }
        /// <summary>
        /// Gets the Base type if it is shared between these two types
        /// </summary>
        public static Type GetSharedBaseType(Type T1, Type T2)
        {
            if (T1 == T2) return T1;
            Type b1 = T1;
            while (b1 != null)
            {
                if (b1.IsAssignableFrom(T2))
                { T1 = b1; break; }
                b1 = b1.BaseType;
            }
            Type b2 = T2;
            while (b2 != null)
            {
                if (b2.IsAssignableFrom(T1))
                { T2 = b2; break; }
                b2 = b2.BaseType;
            }
            return T1 == T2 ? T1 : null;
        }
        #endregion
    }
}
