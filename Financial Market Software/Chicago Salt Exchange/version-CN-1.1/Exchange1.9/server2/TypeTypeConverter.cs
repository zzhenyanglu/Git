using System;
using System.Collections.Generic;
using System.ComponentModel;

using System.Text;

namespace client
{
    /// <summary>
    /// Convert from string to Type
    /// </summary>
    public class TypeTypeConverter : StringConverter
    {
        public override bool CanConvertFrom(ITypeDescriptorContext context, Type sourceType)
        {
            return sourceType == typeof(string);
        }

        public override bool CanConvertTo(ITypeDescriptorContext context, Type destinationType)
        {
            return typeof(Type).IsAssignableFrom(destinationType);
        }

        public override object ConvertFrom(ITypeDescriptorContext context, System.Globalization.CultureInfo culture, object value)
        {
            if (value is string)
                return Utility.GetType(value + "");
            return null;
        }

        public override object ConvertTo(ITypeDescriptorContext context, System.Globalization.CultureInfo culture, object value, Type destinationType)
        {
            if (value is Type)
                return Utility.GetTypeFullName(value as Type, null);
            return null;
        }
    }
}
