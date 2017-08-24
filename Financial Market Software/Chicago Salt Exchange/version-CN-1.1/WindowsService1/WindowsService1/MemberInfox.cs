using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Reflection;

namespace client
{
    /// <summary>
    /// This class make deal with PropertyInfo or FieldInfo as the same way
    /// </summary>
    public class MemberInfox
    {
        private MemberInfo Member;
        public Type ObjectType, ValueType, MemberType;
        /// <summary>
        /// Gets the object instance that contains this property
        /// </summary>
        public object ProbertyObject;
        public string Name;
        public bool MemberExists { get { return Member != null; } }
        public bool CanRead, CanWrite;
        public MemberInfox(object ProbertyObject, string Name, bool SearchForPriviteFieldInCasePublicFieldIsReadOnly=true)
        {
            this.ProbertyObject = ProbertyObject;
            this.Name = Name;
            this.ObjectType =ProbertyObject==null?null: ProbertyObject.GetType();
            Member = Utility.GetMemberInfo(ObjectType, Name, SearchForPriviteFieldInCasePublicFieldIsReadOnly);
            if (Member is PropertyInfo)
            {
                MemberType = (Member as PropertyInfo).PropertyType;
                CanRead = (Member as PropertyInfo).GetGetMethod(true) != null;
                CanWrite = (Member as PropertyInfo).GetSetMethod(true) != null;
            }
            else if (Member is FieldInfo)
            {
                MemberType = (Member as FieldInfo).FieldType;
                CanRead = CanWrite = true;
            }
            else return;

            var val = GetValue();
            if (val != null)
                ValueType = val.GetType();
            else ValueType = MemberType;
        }

        /// <summary>
        /// Gets the runtime current value of this property of field
        /// </summary>
        /// <returns></returns>
        public object GetValue()
        {
            if (!CanRead)
                return null;
            try
            {
                if (Member is PropertyInfo)
                    return (Member as PropertyInfo).GetValue(ProbertyObject, null);
                else if (Member is FieldInfo)
                    return (Member as FieldInfo).GetValue(ProbertyObject);
            }
            catch { }
            return null;
        }
        /// <summary>
        /// Sets the runtime current value of this property of field
        /// </summary>
        public bool SetValue(object value)
        {
            try
            {
                if (!CanWrite||!MemberExists)
                    return false;
                if (value == null && MemberType.IsValueType)
                    return false;
                if (MemberType.IsEnum)
                {
                    if (!Enum.IsDefined(MemberType, value + ""))
                        return false;
                    else if (value != null && value.GetType() != MemberType)
                        value = Enum.Parse(MemberType, value + "");
                }
                if (value != null && !MemberType.IsAssignableFrom(value.GetType()))
                    return false;
                if (Member is PropertyInfo)
                    (Member as PropertyInfo).SetValue(ProbertyObject, value, null);
                else if (Member is FieldInfo)
                    (Member as FieldInfo).SetValue(ProbertyObject, value);
                return true;
            }
            catch { return false; }
        }
        private Dictionary<string, object> customAttributes;
        
        /// <summary>
        /// Gets the runtime current value of this property of field
        /// </summary>
        /// <returns></returns>
        public object GetCustomAttributes(Type attributeType)
        {
            string key = attributeType.FullName;
            if (customAttributes == null) 
                customAttributes = new Dictionary<string, object>();
            if (!customAttributes.ContainsKey(key))
            {
                object[] a;
                try { a = Member.GetCustomAttributes(attributeType, true); }
                catch { a = null; }
                if (a == null || a.Length == 0) customAttributes[key] = null;
                else customAttributes[key] = a[0];
            }
            return customAttributes[key];
        }

        public override string ToString()
        {
            return Name;
        }
        public static List<MemberInfox> GetMemberInfox(object obj, bool SearchForPriviteFieldInCasePublicFieldIsReadOnly = true,bool ReturnOnlyChangedProperties=true)
        {
            List<MemberInfox> members = new List<MemberInfox>();
            if (obj == null) return members;
            var type = obj.GetType();
            while (type!=null&& type != typeof(object))
            {
                foreach (PropertyDescriptor prop in Utility.GetPropertyDescriptors(type))
                {
                    try
                    {
                        if (ReturnOnlyChangedProperties && !prop.ShouldSerializeValue(obj)) continue;
                        if (members.Exists(m => m.Name == prop.Name)) continue;
                        members.Add(new MemberInfox(obj, prop.Name, SearchForPriviteFieldInCasePublicFieldIsReadOnly));
                    }
                    catch { }
                }
                type = type.BaseType;
            }
            return members;
        }
    }
}
