# //blogs.sun.com/GullFOSS/entry/the_jruby_hello_world_example
require 'java'

# some uno type definitions for UnoRuntime.queryInterface(java class, object)
resolvertype = com.sun.star.bridge.XUnoUrlResolver
loadertype = com.sun.star.frame.XComponentLoader
documenttype = com.sun.star.text.XTextDocument
contexttype = com.sun.star.uno.XComponentContext
propertytype = com.sun.star.beans.XPropertySet

# service names - the following are Ruby strings, actually. They are transformed
# automatically into a Java strings when used in that context
urlresolver = "com.sun.star.bridge.UnoUrlResolver"
desktop = "com.sun.star.frame.Desktop"

# helper class with "static" declaration
class Uno
  class << self
    def query(type, object)
      # notice the JRuby method to get the java class from "type";
      # the result of the last line is always the return type and JRuby
      # duck-types, so there is no need for a cast to the Java type;
      # I used the Ruby syntax to access the UnoRuntime class,
      Java::com::sun::star::uno::UnoRuntime.query_interface(type.java_class, object)
      # but the following would also work:
      #com.sun.star.uno.UnoRuntime.queryInterface(type.java_class, object)
      # even a mixture of both is possible
    end
  end
end

# use the Ruby feature to extend classes on the fly, here I extend the service
# manager with a new method called "info". This is a bit evil, because the
# ServiceManager implementation is not part of the API of OpenOffice.org and
# mere an implementation detail.
class Java::com::sun::star::comp::servicemanager::ServiceManager
  def info
    # get the service names
    names = getAvailableServiceNames()
    # print each name
    names.each {|n| puts "Service #{n}"}
  end
end

# create local component context, nil means null in Java
component_context = com::sun::star::comp::helper::Bootstrap.createInitialComponentContext(nil)
# get the service manager
msf = component_context.getServiceManager()
# use the added method above to print all service names
msf.info
# create a UnoUrlResolver - and query for the type
url_resolver = Uno.query(resolvertype, msf.createInstanceWithContext(urlresolver, component_context))
# resolve the remote connection (pep> to previously started >$ soffice.exe "-accept=pipe,name=jrubypipe;urp;")
remote_connection = url_resolver.resolve("uno:pipe,name=jrubypipe;urp;StarOffice.ServiceManager")

# get the property set from the remote OpenOffice.org instance
property_set = Uno.query(propertytype, remote_connection)
# get the default context property and query for the type
remote_context = Uno.query(contexttype, property_set.getPropertyValue("DefaultContext"))
# get the remote service manager - now we're all set!
remote_msf = remote_context.getServiceManager()

# now that the connection is established, do something with the Office
# create a desktop instance and query the component loader type
loader = Uno.query(loadertype, remote_msf.createInstanceWithContext(desktop, remote_context))
# load an empty writer document - notice the creation of an empty Java type array at the end
component = loader.loadComponentFromURL("private:factory/swriter", "_blank", 0,
  Java::com.sun.star.beans.PropertyValue[0].new)
# query the text document type
document = Uno.query(documenttype, component)

# insert the Hello Ruby World text
document.getText().createTextCursor().setString("Hello Ruby World")

puts "Finished."
