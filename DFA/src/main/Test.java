package main;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class Test {

	public static void main(String[] args) {

		/*
		File input = new File("input.txt");
		Scanner scanner = null;
		
		try{
			scanner = new Scanner(input);
		}
		catch(FileNotFoundException e){
			e.printStackTrace();
		}
		
		while(scanner.hasNextLine()){
			System.out.println(scanner.nextLine());
		}
		*/
		char[] E = new char[93];

		String pattern = "abcababacaba#";
		for (char i = 0; i < 93; ++i){
			E[i] = (char)(i + 33);
		}
		
		Transition t = new Transition();	
		int[][] d = t.computeTransitionFunction(pattern, E);
		
		String s = "adceadabca#@babaabcababacaba#cabaa$#dceaab";
		char[] T = s.toCharArray();
		
		Matcher matcher = new Matcher();
		
		matcher.FAM(T, d, pattern.length());
	}

}
