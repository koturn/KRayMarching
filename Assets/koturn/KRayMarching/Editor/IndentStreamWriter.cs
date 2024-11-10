using System;
using System.Collections.Generic;
using System.IO;
using System.Text;


namespace Koturn.KRayMarching
{
    /// <summary>
    /// TextWriter with indenting.
    /// </summary>
    public sealed class IndentStreamWriter : StreamWriter
    {
        /// <summary>
        /// Default indent string.
        /// </summary>
        public const string DefaultIndentString = "    ";

        /// <summary>
        /// Indent is needed before next writing.
        /// </summary>
        private bool _isIndentNeeded;
        /// <summary>
        /// Current indent level.
        /// </summary>
        private int _indentLevel;
        /// <summary>
        /// Indent string list.
        /// </summary>
        private List<string> _indentStringList;
        /// <summary>
        /// Current indent string.
        /// </summary>
        private string _currentIndentString;
        /// <summary>
        /// One indent string.
        /// </summary>
        public string IndentString { get; }

        /// <summary>
        /// Set or get current indent level.
        /// </summary>
        public int IndentLevel
        {
            get { return _indentLevel; }
            set
            {
                if (value < 0)
                {
                    ThrowArgumentOutOfRangeException(nameof(IndentLevel), value, $"{IndentLevel} must be 0 or positive value");
                }
                _indentLevel = value;
                _currentIndentString = GetIndent(value);
            }
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="IndentStreamWriter"/> class for the specified stream
        /// by using UTF-8 encoding and the default buffer size.
        /// </summary>
        /// <param name="stream">The stream to write to.</param>
        /// <param name="indentString">Indent string.</param>
        /// <exception cref="ArgumentException"><paramref name="stream"/> is not writable.</exception>
        /// <exception cref="ArgumentNullException"><paramref name="stream"/> is null.</exception>
        public IndentStreamWriter(Stream stream, string indentString = DefaultIndentString)
            : base(stream)
        {
            _isIndentNeeded = false;
            _indentLevel = 0;
            _indentStringList = new List<string>();
            _currentIndentString = string.Empty;
            IndentString = indentString;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="IndentStreamWriter"/> class for the specified file
        /// by using the default encoding and buffer size.
        /// </summary>
        /// <param name="path">The complete file path to write to. path can be a file name.</param>
        /// <param name="indentString">Indent string.</param>
        /// <exception cref="UnauthorizedAccessException">Access is denied.</exception>
        /// <exception cref="ArgumentException"><paramref name="path"/> is an empty string (""). -or- path contains the name of a system device (com1, com2, and so on).</exception>
        /// <exception cref="ArgumentNullException"><paramref name="path"/> is null.</exception>
        /// <exception cref="DirectoryNotFoundException">The specified path is invalid (for example, it is on an unmapped drive).</exception>
        /// <exception cref="PathTooLongException">The specified path, file name, or both exceed the system-defined maximum length.</exception>
        /// <exception cref="IOException"><paramref name="path"/> includes an incorrect or invalid syntax for file name, directory name, or volume label syntax.</exception>
        /// <exception cref="System.Security.SecurityException">The caller does not have the required permission.</exception>
        public IndentStreamWriter(string path, string indentString = DefaultIndentString)
            : base(path)
        {
            _isIndentNeeded = false;
            _indentLevel = 0;
            _indentStringList = new List<string>();
            _currentIndentString = string.Empty;
            IndentString = indentString;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="IndentStreamWriter"/> class for the specified stream
        /// by using the specified encoding and the default buffer size.
        /// </summary>
        /// <param name="stream">The stream to write to.</param>
        /// <param name="encoding">The character encoding to use.</param>
        /// <param name="indentString">Indent string.</param>
        /// <exception cref="ArgumentException"><paramref name="stream"/> is not writable.</exception>
        /// <exception cref="ArgumentNullException"><paramref name="stream"/> or <paramref name="encoding"/> is null.</exception>
        public IndentStreamWriter(Stream stream, Encoding encoding, string indentString = DefaultIndentString)
            : base(stream, encoding)
        {
            _isIndentNeeded = false;
            _indentLevel = 0;
            _indentStringList = new List<string>();
            _currentIndentString = string.Empty;
            IndentString = indentString;
        }

        /// <summary>
        /// <para>Initializes a new instance of the <see cref="IndentStreamWriter"/> class for the specified file
        /// by using the default encoding and buffer size.</para>
        /// <para>If the file exists, it can be either overwritten or appended to.</para>
        /// <para>If the file does not exist, this constructor creates a new file.</para>
        /// </summary>
        /// <param name="path">The complete file path to write to.</param>
        /// <param name="append">
        /// <para>true to append data to the file; false to overwrite the file</para>
        /// <para>If the specified file does not exist, this parameter has no effect, and the constructor creates a new file.</para>
        /// </param>
        /// <param name="indentString">Indent string.</param>
        /// <exception cref="UnauthorizedAccessException">Access is denied.</exception>
        /// <exception cref="ArgumentException"><paramref name="path"/> is an empty string (""). -or- path contains the name of a system device (com1, com2, and so on).</exception>
        /// <exception cref="ArgumentNullException"><paramref name="path"/> is null.</exception>
        /// <exception cref="DirectoryNotFoundException">The specified path is invalid (for example, it is on an unmapped drive).</exception>
        /// <exception cref="PathTooLongException">The specified path, file name, or both exceed the system-defined maximum length.</exception>
        /// <exception cref="IOException"><paramref name="path"/> includes an incorrect or invalid syntax for file name, directory name, or volume label syntax.</exception>
        /// <exception cref="System.Security.SecurityException">The caller does not have the required permission.</exception>
        public IndentStreamWriter(string path, bool append, string indentString = DefaultIndentString)
            : base(path, append)
        {
            _isIndentNeeded = false;
            _indentLevel = 0;
            _indentStringList = new List<string>();
            _currentIndentString = string.Empty;
            IndentString = indentString;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="IndentStreamWriter"/> class for the specified stream
        /// by using the specified encoding and buffer size.
        /// </summary>
        /// <param name="stream">The stream to write to.</param>
        /// <param name="encoding">The character encoding to use.</param>
        /// <param name="bufferSize">The buffer size, in bytes.</param>
        /// <param name="indentString">Indent string.</param>
        /// <exception cref="ArgumentException"><paramref name="stream"/> is not writable.</exception>
        /// <exception cref="ArgumentNullException"><paramref name="stream"/> or <paramref name="encoding"/> is null.</exception>
        /// <exception cref="ArgumentOutOfRangeException"><paramref name="bufferSize"/> is negative.</exception>
        public IndentStreamWriter(Stream stream, Encoding encoding, int bufferSize, string indentString = DefaultIndentString)
            : base(stream, encoding, bufferSize)
        {
            _isIndentNeeded = false;
            _indentLevel = 0;
            _indentStringList = new List<string>();
            _currentIndentString = string.Empty;
            IndentString = indentString;
        }

        /// <summary>
        /// <para>Initializes a new instance of the <see cref="IndentStreamWriter"/> class for the specified file
        /// by using the specified encoding and default buffer size.</para>
        /// <para>If the file exists, it can be either overwritten or appended to.</para>
        /// <para>If the file does not exist, this constructor creates a new file.</para>
        /// </summary>
        /// <param name="path">The complete file path to write to.</param>
        /// <param name="append">
        /// <para>true to append data to the file; false to overwrite the file.</para>
        /// <para>If the specified file does not exist, this parameter has no effect, and the constructor creates a new file.</para>
        /// </param>
        /// <param name="encoding">The character encoding to use.</param>
        /// <param name="indentString">Indent string.</param>
        /// <exception cref="UnauthorizedAccessException">Access is denied.</exception>
        /// <exception cref="ArgumentException"><paramref name="path"/> is an empty string (""). -or- path contains the name of a system device (com1, com2, and so on).</exception>
        /// <exception cref="ArgumentNullException"><paramref name="path"/> is null.</exception>
        /// <exception cref="DirectoryNotFoundException">The specified path is invalid (for example, it is on an unmapped drive).</exception>
        /// <exception cref="PathTooLongException">The specified path, file name, or both exceed the system-defined maximum length.</exception>
        /// <exception cref="IOException"><paramref name="path"/> includes an incorrect or invalid syntax for file name, directory name, or volume label syntax.</exception>
        /// <exception cref="System.Security.SecurityException">The caller does not have the required permission.</exception>
        public IndentStreamWriter(string path, bool append, Encoding encoding, string indentString = DefaultIndentString)
           : base(path, append, encoding)
        {
            _isIndentNeeded = false;
            _indentLevel = 0;
            _indentStringList = new List<string>();
            _currentIndentString = string.Empty;
            IndentString = indentString;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="IndentStreamWriter"/> class for the specified stream
        /// by using the specified encoding and buffer size, and optionally leaves the stream open.
        /// </summary>
        /// <param name="stream">The stream to write to.</param>
        /// <param name="encoding">The character encoding to use.</param>
        /// <param name="bufferSize">The buffer size, in bytes.</param>
        /// <param name="leaveOpen">true to leave the stream open after the System.IO.StreamWriter object is disposed; otherwise, false.</param>
        /// <param name="indentString">Indent string.</param>
        /// <exception cref="ArgumentException"><paramref name="stream"/> is not writable.</exception>
        /// <exception cref="ArgumentNullException"><paramref name="stream"/> or <paramref name="encoding"/> is null.</exception>
        /// <exception cref="ArgumentOutOfRangeException"><paramref name="bufferSize"/> is negative.</exception>
        public IndentStreamWriter(Stream stream, Encoding encoding = null, int bufferSize = -1, bool leaveOpen = false, string indentString = DefaultIndentString)
            : base(stream, encoding, bufferSize, leaveOpen)
        {
            _isIndentNeeded = false;
            _indentLevel = 0;
            _indentStringList = new List<string>();
            _currentIndentString = string.Empty;
            IndentString = indentString;
        }

        /// <summary>
        /// <para>Initializes a new instance of the <see cref="IndentStreamWriter"/> class for the specified file on the specified path,
        /// using the specified encoding and buffer size.</para>
        /// <para>If the file exists, it can be either overwritten or appended to.</para>
        /// <para>If the file does not exist, this constructor creates a new file.</para>
        /// </summary>
        /// <param name="path">The complete file path to write to.</param>
        /// <param name="append">
        /// <para>true to append data to the file; false to overwrite the file.</para>
        /// <para>If the specified file does not exist, this parameter has no effect, and the constructor creates a new file.</para>
        /// </param>
        /// <param name="encoding">The character encoding to use.</param>
        /// <param name="bufferSize">The buffer size, in bytes.</param>
        /// <param name="indentString">Indent string.</param>
        /// <exception cref="UnauthorizedAccessException">Access is denied.</exception>
        /// <exception cref="ArgumentException"><paramref name="path"/> is an empty string (""). -or- path contains the name of a system device (com1, com2, and so on).</exception>
        /// <exception cref="ArgumentNullException"><paramref name="path"/> is null.</exception>
        /// <exception cref="ArgumentOutOfRangeException"><paramref name="bufferSize"/> is negative.</exception>
        /// <exception cref="DirectoryNotFoundException">The specified path is invalid (for example, it is on an unmapped drive).</exception>
        /// <exception cref="PathTooLongException">The specified path, file name, or both exceed the system-defined maximum length.</exception>
        /// <exception cref="IOException"><paramref name="path"/> includes an incorrect or invalid syntax for file name, directory name, or volume label syntax.</exception>
        /// <exception cref="System.Security.SecurityException">The caller does not have the required permission.</exception>
        public IndentStreamWriter(string path, bool append, Encoding encoding, int bufferSize, string indentString = DefaultIndentString)
            : base(path, append, encoding, bufferSize)
        {
            _isIndentNeeded = false;
            _indentLevel = 0;
            _indentStringList = new List<string>();
            _currentIndentString = string.Empty;
            IndentString = indentString;
        }


        /// <summary>
        /// Writes indent if needed and writes a character to the stream.
        /// </summary>
        /// <param name="value">The character to write to the stream.</param>
        /// <exception cref="IOException">An I/O error occurs.</exception>
        /// <exception cref="ObjectDisposedException"><see cref="StreamWriter.AutoFlush"/> is true
        /// or the <see cref="StreamWriter"/> buffer is full, and current writer is closed.</exception>
        /// <exception cref="NotSupportedException"><see cref="StreamWriter.AutoFlush"/> is true
        /// or the <see cref="StreamWriter"/> buffer is full, and the contents of the buffer cannot be written
        /// to the underlying fixed size stream because the <see cref="StreamWriter"/> is at the end the stream.</exception>
        public override void Write(char value)
        {
            WriteIndentIfNeeded();
            base.Write(value);
            _isIndentNeeded = false;
        }

        /// <summary>
        /// Writes indent if needed and writes a character array to the stream.
        /// </summary>
        /// <param name="buffer">A character array containing the data to write.
        /// If <paramref name="buffer"/> is null, nothing is written.</param>
        /// <exception cref="IOException">An I/O error occurs.</exception>
        /// <exception cref="ObjectDisposedException"><see cref="StreamWriter.AutoFlush"/> is true
        /// or the <see cref="StreamWriter"/> buffer is full, and current writer is closed.</exception>
        /// <exception cref="NotSupportedException"><see cref="StreamWriter.AutoFlush"/> is true
        /// or the <see cref="StreamWriter"/> buffer is full, and the contents of the buffer cannot be written
        /// to the underlying fixed size stream because the <see cref="StreamWriter"/> is at the end the stream.</exception>
        public override void Write(char[] buffer)
        {
            WriteIndentIfNeeded();
            base.Write(buffer);
            _isIndentNeeded = false;
        }

        /// <summary>
        /// Writes indent if needed and writes a subarray of characters to the stream.
        /// </summary>
        /// <param name="buffer">A character array that contains the data to write.</param>
        /// <param name="index">The character position in the buffer at which to start reading data.</param>
        /// <param name="count">The maximum number of characters to write.</param>
        /// <exception cref="ArgumentNullException"><paramref name="buffer"/> is null.</exception>
        /// <exception cref="ArgumentException">The <paramref name="buffer"/> length minus index is less than <paramref name="count"/>.</exception>
        /// <exception cref="ArgumentOutOfRangeException"><paramref name="index"/> or <paramref name="count"/> is negative.</exception>
        /// <exception cref="IOException">An I/O error occurs.</exception>
        /// <exception cref="ObjectDisposedException"><see cref="StreamWriter.AutoFlush"/> is true
        /// or the <see cref="StreamWriter"/> buffer is full, and current writer is closed.</exception>
        /// <exception cref="NotSupportedException"><see cref="StreamWriter.AutoFlush"/> is true
        /// or the <see cref="StreamWriter"/> buffer is full, and the contents of the buffer cannot be written
        /// to the underlying fixed size stream because the <see cref="StreamWriter"/> is at the end the stream.</exception>
        public override void Write(char[] buffer, int index, int count)
        {
            WriteIndentIfNeeded();
            base.Write(buffer, index, count);
            _isIndentNeeded = false;
        }

        /// <summary>
        /// Writes indent if needed and writes a string to the stream.
        /// </summary>
        /// <param name="value">The string to write to the stream.
        /// If <paramref name="value"/> is null, nothing is written.</param>
        public override void Write(string value)
        {
            WriteIndentIfNeeded();
            base.Write(value);
            _isIndentNeeded = false;
        }

        /// <summary>
        /// Writes indent if needed and writes a formatted string to the stream,
        /// using the same semantics as the <see cref="string.Format(string, object )"/> method.
        /// </summary>
        /// <param name="format">A composite format string.</param>
        /// <param name="arg0">The object to format and write.</param>
        public override void Write(string format, object arg0)
        {
            base.Write(format, arg0);
            _isIndentNeeded = false;
        }

        /// <summary>
        /// Writes indent if needed and writes a formatted string to the stream,
        /// using the same semantics as the <see cref="string.Format(string, object, object)"/> method.
        /// </summary>
        /// <param name="format">A composite format string.</param>
        /// <param name="arg0">The first object to format and write.</param>
        /// <param name="arg1">The second object to format and write.</param>
        public override void Write(string format, object arg0, object arg1)
        {
            base.Write(format, arg0, arg1);
            _isIndentNeeded = false;
        }

        /// <summary>
        /// Writes indent if needed and writes a formatted string to the stream,
        /// using the same semantics as the <see cref="string.Format(string, object, object, object)"/> method.
        /// </summary>
        /// <param name="format">A composite format string.</param>
        /// <param name="arg0">The first object to format and write.</param>
        /// <param name="arg1">The second object to format and write.</param>
        /// <param name="arg2">The third object to format and write.</param>
        public override void Write(string format, object arg0, object arg1, object arg2)
        {
            base.Write(format, arg0, arg1, arg2);
            _isIndentNeeded = false;
        }

        /// <summary>
        /// Writes indent if needed and writes a formatted string to the stream,
        /// using the same semantics as the <see cref="string.Format(string, object[])"/> method.
        /// </summary>
        /// <param name="format">A composite format string.</param>
        /// <param name="arg">An object array that contains zero or more objects to format and write.</param>
        public override void Write(string format, params object[] arg)
        {
            base.Write(format, arg);
            _isIndentNeeded = false;
        }

        /// <summary>
        /// Writes a line terminator to the text stream.
        /// </summary>
        public override void WriteLine()
        {
            _isIndentNeeded = false;
            base.WriteLine();
            _isIndentNeeded = true;
        }

        /// <summary>
        /// Writes indent if needed and writes a string to the stream, followed by a line terminator.
        /// </summary>
        /// <param name="value">The string to write. If <paramref name="value"/> is null, only the line terminator is written.</param>
        public override void WriteLine(string value)
        {
            base.WriteLine(value);
            _isIndentNeeded = true;
        }

        /// <summary>
        /// Writes indent if needed and writes out a formatted string and a new line to the stream,
        /// using the same semantics as the <see cref="string.Format(string, object)"/>.
        /// </summary>
        /// <param name="format">A composite format string.</param>
        /// <param name="arg0">The first object to format and write.</param>
        public override void WriteLine(string format, object arg0)
        {
            base.WriteLine(format, arg0);
            _isIndentNeeded = true;
        }

        /// <summary>
        /// Writes indent if needed and writes out a formatted string and a new line to the stream,
        /// using the same semantics as the <see cref="string.Format(string, object, object)"/>.
        /// </summary>
        /// <param name="format">A composite format string.</param>
        /// <param name="arg0">The first object to format and write.</param>
        /// <param name="arg1">The second object to format and write.</param>
        public override void WriteLine(string format, object arg0, object arg1)
        {
            base.WriteLine(format, arg0, arg1);
            _isIndentNeeded = true;
        }

        /// <summary>
        /// Writes indent if needed and writes out a formatted string and a new line to the stream,
        /// using the same semantics as the <see cref="string.Format(string, object, object, object)"/>.
        /// </summary>
        /// <param name="format">A composite format string.</param>
        /// <param name="arg0">The first object to format and write.</param>
        /// <param name="arg1">The second object to format and write.</param>
        /// <param name="arg2">The third object to format and write.</param>
        public override void WriteLine(string format, object arg0, object arg1, object arg2)
        {
            base.WriteLine(format, arg0, arg1, arg2);
            _isIndentNeeded = true;
        }

        /// <summary>
        /// Writes indent if needed and writes out a formatted string and a new line to the stream,
        /// using the same semantics as the <see cref="string.Format(string, object[])"/>.
        /// </summary>
        /// <param name="format">A composite format string.</param>
        /// <param name="arg">An object array that contains zero or more objects to format and write.</param>
        public override void WriteLine(string format, params object[] arg)
        {
            base.WriteLine(format, arg);
            _isIndentNeeded = true;
        }

        /// <summary>
        /// Writes line terminators to the text stream.
        /// </summary>
        /// <param name="nLines">Count of line terminators to write.</param>
        public void WriteEmptyLines(int nLines)
        {
            _isIndentNeeded = false;
            for (int i = 0; i < nLines; i++)
            {
                base.WriteLine();
            }
            _isIndentNeeded = true;
        }

        /// <summary>
        /// Write indent if needed.
        /// </summary>
        /// <remarks>
        /// <seealso cref="_isIndentNeeded"/>
        /// </remarks>
        private void WriteIndentIfNeeded()
        {
            if (_isIndentNeeded)
            {
                base.Write(_currentIndentString);
            }
        }

        /// <summary>
        /// Get indent string for the specified level.
        /// </summary>
        /// <param name="indentLevel">Indentation level.</param>
        /// <returns>Indent string for the <paramref name="indentLevel"/>.</returns>
        private string GetIndent(int indentLevel)
        {
            var indentStringList = _indentStringList;
            if (indentLevel >= indentStringList.Count)
            {
                EnsureIndentStringList(indentLevel);
            }

            return indentStringList[indentLevel];
        }

        /// <summary>
        /// Ensure (cache) indent string for the specified level.
        /// </summary>
        /// <param name="indentLevel">Indentation level.</param>
        private void EnsureIndentStringList(int indentLevel)
        {
            var indentStringList = _indentStringList;
            for (int i = indentStringList.Count; i <= indentLevel; i++)
            {
                indentStringList.Add(i == 0 ? string.Empty : (indentStringList[i - 1] + IndentString));
            }
        }


        /// <summary>
        /// Throws <see cref="ArgumentOutOfRangeException"/>.
        /// </summary>
        /// <param name="paramName">The name of the parameter that caused the exception.</param>
        /// <param name="actualValue">The value of the argument that causes this exception.</param>
        /// <param name="message">The message that describes the error.</param>
        /// <exception cref="ArgumentOutOfRangeException">Always thrown.</exception>
        private static void ThrowArgumentOutOfRangeException(string paramName, object actualValue, string message)
        {
            throw new ArgumentOutOfRangeException(paramName, actualValue, message);
        }
    }
}
