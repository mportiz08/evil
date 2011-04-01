FILES=Evil.java
ALL= Evil.class antlr.generated antlr.generated.evil antlr.generated.type

all: ${ALL}

Evil.class : antlr.generated ${FILES}
	javac *.java

antlr.generated: antlr.generated.evil antlr.generated.type
	touch antlr.generated

antlr.generated.evil : Evil.g
	java org.antlr.Tool Evil.g
	touch antlr.generated.evil

antlr.generated.type : TypeCheck.g
	java org.antlr.Tool TypeCheck.g
	touch antlr.generated.type

safe:
	\cp *.g *.java ~/.431
	
clean:
	rm *.class
	rm antlr.generated*
