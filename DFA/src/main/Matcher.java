package main;

public class Matcher {

	public void FAM(char[] T, int[][] d, int m){
		int n = T.length;
		int q = 0;
		int s;
		for(int i = 0; i < n; i++){
			q = d[q][T[i] - 97];
			if(q == m){
				s = i - m;
				System.out.println("wzorzec z przesunieciem" + s);
			}
		}
	}
}
