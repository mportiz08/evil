FILES=Evil.java
ALL= Evil.class antlr.generated antlr.generated.evil antlr.generated.type antlr.generated.iloc

all: ${ALL}

Evil.class : antlr.generated ${FILES}
	javac *.java

antlr.generated: antlr.generated.evil antlr.generated.type antlr.generated.iloc
	touch antlr.generated

antlr.generated.evil : Evil.g
	java org.antlr.Tool Evil.g
	touch antlr.generated.evil

antlr.generated.type : TypeCheck.g
	java org.antlr.Tool TypeCheck.g
	touch antlr.generated.type
	
antlr.generated.iloc : ILOC.g
	java org.antlr.Tool ILOC.g
	touch antlr.generated.iloc

safe:
	\cp *.g *.java ~/.431
	
clean:
	rm *.class
	rm antlr.generated*
