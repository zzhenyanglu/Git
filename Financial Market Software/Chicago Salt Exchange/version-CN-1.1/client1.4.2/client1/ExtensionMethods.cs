
using System;
using System.Collections;
using System.Collections.Generic;

using System.Text;

namespace client
{
    public static class ExtensionMethods
    {
     
        /// <summary>
        /// Determine if the Input value can be converted to TargetType
        /// </summary>
        public static bool CanConvertTo(this object Input, Type TargetType)
        {
            if (Input == null || Input.GetType().IsAssignableFrom(TargetType) || TargetType.IsAssignableFrom(Input.GetType()) || TargetType == typeof(string)) return true;
            return Utility.GetConverter(Input.GetType()).CanConvertTo(TargetType) ||
                   Utility.GetConverter(TargetType).CanConvertFrom(Input.GetType()) ||
                   (TargetType.IsEnumType() && Input.GetType().IsEnumType());
        }
        /// <summary>
        /// Convert value to specific T type
        /// </summary>
        public static T ConvertTo<T>(this object Input, OnErrorAction OnErrorAction = OnErrorAction.ThrowException)
        {
            return (T)ConvertTo(Input, typeof(T), OnErrorAction);
        }
     

        /// <summary>
        /// Convert value to specific T type
        /// </summary>
        public static object ConvertTo(this object Input, Type TargetType, OnErrorAction OnErrorAction = OnErrorAction.ThrowException)
        {
            if (Input == null || TargetType.IsAssignableFrom(Input.GetType())) return Input;
            if (TargetType == typeof(string))
                try { return Utility.GetConverter(Input.GetType()).ConvertTo(Input, TargetType); }
                catch { return Input.ToString(); }
            
            if (!CanConvertTo(Input, TargetType))
            {
                if (OnErrorAction == OnErrorAction.ThrowException)
                    throw new Exception("Can't convert type " + Input.GetType().Name + " to type " + TargetType.Name);
                else if (OnErrorAction == OnErrorAction.ReturnNull)
                    return Utility.GetDefault(TargetType);
                else return Input;
            }
            try
            {
                if (TargetType.IsEnumType() && Input.GetType().IsEnumType())
                    Input = Input + "";
                try { return Utility.GetConverter(TargetType).ConvertFrom(Input); }
                catch(Exception ex)
                {
                    if (TargetType == typeof(string) && Input is IList)
                        return Utility.SerializeArrayAsString(Input as IList);
                    if (TargetType.IsList() && Input.GetType() == typeof(string))
                        return Utility.DeSerializeArrayFromString(TargetType, Input as string);
                    throw ex;
                }
            }
            catch
            {
                try { return Utility.GetConverter(Input.GetType()).ConvertTo(Input, TargetType); }
                catch
                {
                    if (OnErrorAction == OnErrorAction.ThrowException)
                        throw;
                    else if (OnErrorAction == OnErrorAction.ReturnNull)
                        return Utility.GetDefault(TargetType);
                    else return Input;
                }
            }
        }


        /// <summary>
        /// Populate this row from SourceObject
        /// </summary>
        public static void Populate(this System.Data.DataRow Row, object SourceObject)
        {
            foreach (System.Data.DataColumn column in Row.Table.Columns)
                Row[column] = Utility.GetPropertyInfox(SourceObject, column.ColumnName).GetValue();
        }
        /// <summary>
        /// Populate this table from SourceList
        /// </summary>
        public static void Populate(this System.Data.DataTable Table, System.Collections.IList SourceList)
        {
            foreach (var item in SourceList)
            {
                var row = Table.NewRow();
                row.Populate(item);
                Table.Rows.Add(row);
            }
        }
        /// <summary>
        /// Convert this SourceList to DataTable instance.
        /// DataTable.Columns are the name of the properties in each list item.
        /// </summary>
        public static System.Data.DataTable ToDataTable(this System.Collections.IList SourceList, string TableName)
        {
            System.Data.DataTable table = new System.Data.DataTable(TableName);
            if (SourceList.Count > 0)
            {
                foreach (var item in MemberInfox.GetMemberInfox(SourceList[0]))
                    table.Columns.Add(item.Name, item.MemberType);
                table.Populate(SourceList);
            }
            return table;
        }
        /// <summary>
        /// Add range values to this List
        /// </summary>
        public static void AddRange(this System.Collections.IList Collection, System.Collections.IEnumerable Items,bool AllowRepeatedValues=true)
        {
            foreach (var item in Items)
            {
                if (!AllowRepeatedValues && Collection.Contains(item)) continue;
                Collection.Add(item);
            }
        }
        static Dictionary<System.Collections.IList, string> isInside = new Dictionary<System.Collections.IList, string>();
        /// <summary>
        /// Make sure this list contains only these items.
        /// </summary>
        public static void SetItems(this System.Collections.IList List,  System.Collections.IList Items)
        {
            if (isInside.ContainsKey(List)) return;
            try
            {
                isInside[List] = null;
                for (int i = 0; i < List.Count; i++)
                {
                    var item = List[i];
                    if (Items.Contains(item)) continue;
                    List.Remove(item);
                    i--;
                }
                foreach (var item in Items)
                    if (!List.Contains(item))
                        List.Add(item);
            }
            finally
            {
                isInside.Remove(List);
            }


        }
        /// <summary>
        /// Convert this list to an array
        /// </summary>
        public static T[] ToArrayOfT<T>(this System.Collections.IList Collection)
        {
            T[] array = new T[Collection.Count];
            Collection.CopyTo(array, 0);
            return array;
        }
        /// <summary>
        /// Convert this list to an array
        /// </summary>
        public static object[] ToArrayOfObject(this System.Collections.IList Collection)
        {
            object[] array = new object[Collection.Count];
            Collection.CopyTo(array, 0);
            return array;
        }
        /// <summary>
        /// Gets the First element if this Collection
        /// </summary>
        public static T FirstOrDefault<T>(this System.Collections.IList Collection)
        {
            if (Collection.Count == 0)
                return default(T);
            return (T)Collection[0];
        }


        /// <summary>
        /// Find the index of the first item which match the Predicate method
        /// </summary>
        public static int FindIndex<T>(this System.Collections.IList Collection, Predicate<T> match)
        {
            for (int i = 0; i < Collection.Count; i++)
                if (match((T)Collection[i]))
                    return i;
            return -1;
        }
        /// <summary>
        /// Determine if thie type of this object is a numeric type such as int,long,double,...
        /// </summary>
        public static bool IsNumericType(this object o)
        {
            if (o == null) return false;
            return o.GetType().IsNumericType();
        }
        /// <summary>
        /// Determine if thie type is a numeric type such as int,long,double,...
        /// </summary>
        public static bool IsNumericType(this Type o)
        {
            if (o.IsNullableType() && Nullable.GetUnderlyingType(o) != null)
                return IsNumericType(Nullable.GetUnderlyingType(o));
            else switch (Type.GetTypeCode(o))
            {
                case TypeCode.Byte:
                case TypeCode.SByte:
                case TypeCode.UInt16:
                case TypeCode.UInt32:
                case TypeCode.UInt64:
                case TypeCode.Int16:
                case TypeCode.Int32:
                case TypeCode.Int64:
                case TypeCode.Decimal:
                case TypeCode.Double:
                case TypeCode.Single:
                    return true;
                default:
                    return false;
            }
        }
        /// <summary>
        /// Determine if this type is a float type such as Decimal,Double and Single
        /// </summary>
        public static bool IsNumericFloatType(this Type o)
        {
            if (o.IsNullableType() && Nullable.GetUnderlyingType(o) != null)
                return IsNumericFloatType(Nullable.GetUnderlyingType(o));
            else switch (Type.GetTypeCode(o))
                {
                    case TypeCode.Decimal:
                    case TypeCode.Double:
                    case TypeCode.Single:
                        return true;
                    default:
                        return false;
                }
        }

        /// <summary>
        /// Determine if this type is an Enum Type
        /// </summary>
        /// <param name="PropertyType"></param>
        /// <returns></returns>
        public static bool IsEnumType(this Type PropertyType)
        {
            return PropertyType.GetUnderlyingType().IsEnum;
        }
        /// <summary>
        /// Gets the GetUnderlyingType in the PropertyType is Nullable, if not, then retuen the same PropertyType
        /// </summary>
        /// <param name="PropertyType"></param>
        /// <returns></returns>
        public static Type GetUnderlyingType(this Type PropertyType)
        {
            if (PropertyType == null) return null;
            return PropertyType.IsNullableType() && Nullable.GetUnderlyingType(PropertyType) != null ? Nullable.GetUnderlyingType(PropertyType) : PropertyType;
        }
        /// <summary>
        /// Determine if this type is a List type such as Arrays and any type derive from IList interface
        /// </summary>
        /// <param name="o"></param>
        /// <returns></returns>
        public static bool IsList(this Type o)
        {
            return o!=typeof(string)&& typeof(System.Collections.IList).IsAssignableFrom(o);
        }
        public static bool IsNullableType(this Type type)
        {
            return !type.IsValueType || (type.IsGenericType && (type.GetGenericTypeDefinition() == typeof(Nullable<>)));
        }

        /// <summary>
        /// Determine if the two object have the same value. The input values can be in different types
        /// </summary>
        public static bool ValueEquals(this object val1, object val2)
        {
            if (object.Equals(val1, val2)) return true;
            if (val1 == null && val2 != null)
                return false;
            if (val2 == null && val1 != null)
                return false;
            return object.Equals(val1, val2.ConvertTo(val1.GetType(), OnErrorAction.ReturnTheSameValue))||
                   object.Equals(val2, val1.ConvertTo(val2.GetType(), OnErrorAction.ReturnTheSameValue));
        }


        /// <summary>
        /// Map the wpf cursor name to windows forms cursor name
        /// </summary>
        public static Dictionary<string, string> CursorsNamesMap = new Dictionary<string, string>() 
        {
            {"No","No"},
            {"Arrow","Arrow"},
            {"AppStarting","AppStarting"},
            {"Cross","Cross"},
            {"Help","Help"},
            {"IBeam","IBeam"},
            {"SizeAll","SizeAll"},
            {"SizeNESW","SizeNESW"},
            {"SizeNS","SizeNS"},
            {"SizeNWSE","SizeNWSE"},
            {"SizeWE","SizeWE"},
            {"UpArrow","UpArrow"},
            {"Wait","WaitCursor"},
            {"Hand","Hand"},
            {"ScrollNS","NoMoveVert"},
            {"ScrollWE","NoMoveHoriz"},
            {"ScrollAll","NoMove2D"},
            {"ScrollN","PanNorth"},
            {"ScrollS","PanSouth"},
            {"ScrollW","PanWest"},
            {"ScrollE","PanEast"},
            {"ScrollNW","PanNW"},
            {"ScrollNE","PanNE"},
            {"ScrollSW","PanSW"},
            {"ScrollSE","PanSE"}
        };
    }

    public enum OnErrorAction { ThrowException, ReturnTheSameValue, ReturnNull }
}
